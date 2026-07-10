import AVFoundation

enum ToneShape {
    case square, sawtooth, triangle, noise
}

/// Tiny real-time synth built on an `AVAudioSourceNode` — every effect in the
/// game (launch whoosh, clash clang, spin-out, ring-out, boost, victory
/// fanfare) is generated as short tone/noise voices with an exponential
/// decay envelope. No audio files are bundled.
final class SoundEngine {
    static let shared = SoundEngine()

    private struct Voice {
        let freqStart: Double
        let freqEnd: Double
        let shape: ToneShape
        let gain: Double
        let startSample: Int64
        let durationSamples: Int64
    }

    private let engine = AVAudioEngine()
    private let sampleRate = 44100.0
    private var voices: [Voice] = []
    private let lock = NSLock()
    private var sampleClock: Int64 = 0
    private(set) var isOn: Bool {
        didSet { UserDefaults.standard.set(isOn, forKey: "ibeyblade.sound") }
    }

    private init() {
        isOn = UserDefaults.standard.object(forKey: "ibeyblade.sound") == nil ? true : UserDefaults.standard.bool(forKey: "ibeyblade.sound")

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let source = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buffer = abl[0]
            let ptr = buffer.mData!.assumingMemoryBound(to: Float.self)

            self.lock.lock()
            let localVoices = self.voices
            let startClock = self.sampleClock
            self.lock.unlock()

            for frame in 0..<Int(frameCount) {
                let now = startClock + Int64(frame)
                var sample: Float = 0
                for v in localVoices {
                    guard now >= v.startSample, now < v.startSample + v.durationSamples else { continue }
                    let elapsed = Double(now - v.startSample)
                    let t = elapsed / self.sampleRate
                    let durationSec = Double(v.durationSamples) / self.sampleRate
                    let progress = durationSec > 0 ? t / durationSec : 0
                    let freq = v.freqStart + (v.freqEnd - v.freqStart) * progress
                    let raw: Double
                    switch v.shape {
                    case .square:
                        let ph = (elapsed * freq / self.sampleRate).truncatingRemainder(dividingBy: 1)
                        raw = ph < 0.5 ? 1.0 : -1.0
                    case .sawtooth:
                        let ph = (elapsed * freq / self.sampleRate).truncatingRemainder(dividingBy: 1)
                        raw = 2.0 * ph - 1.0
                    case .triangle:
                        let ph = (elapsed * freq / self.sampleRate).truncatingRemainder(dividingBy: 1)
                        raw = 4.0 * abs(ph - 0.5) - 1.0
                    case .noise:
                        let x = Double(now) * 12.9898 + freq * 0.0001
                        let s = sin(x) * 43758.5453
                        raw = 2 * (s - floor(s)) - 1
                    }
                    let envelope = v.gain * exp(-4.5 * progress)
                    sample += Float(raw * envelope)
                }
                ptr[frame] = max(-1, min(1, sample))
            }

            self.lock.lock()
            self.sampleClock += Int64(frameCount)
            self.voices.removeAll { $0.startSample + $0.durationSamples < self.sampleClock }
            self.lock.unlock()

            return noErr
        }

        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1.0
        try? engine.start()
    }

    func setSoundOn(_ on: Bool) { isOn = on }
    func toggleSound() -> Bool { isOn.toggle(); return isOn }

    func playTone(freq: Double, freqEnd: Double? = nil, duration: Double, shape: ToneShape = .square, gain: Double = 0.18, delay: Double = 0) {
        guard isOn else { return }
        lock.lock()
        let start = sampleClock + Int64(delay * sampleRate)
        voices.append(Voice(freqStart: freq, freqEnd: freqEnd ?? freq, shape: shape, gain: gain, startSample: start, durationSamples: Int64(duration * sampleRate)))
        lock.unlock()
    }

    func playSequence(_ notes: [(freq: Double, freqEnd: Double?, delayMs: Double, duration: Double, shape: ToneShape, gain: Double)]) {
        for n in notes {
            playTone(freq: n.freq, freqEnd: n.freqEnd, duration: n.duration, shape: n.shape, gain: n.gain, delay: n.delayMs / 1000)
        }
    }

    func playLaunch() {
        playTone(freq: 180, freqEnd: 900, duration: 0.35, shape: .sawtooth, gain: 0.16)
        playTone(freq: 2000, freqEnd: 400, duration: 0.3, shape: .noise, gain: 0.1)
    }

    func playClash(intensity: Double) {
        let g = 0.12 + 0.14 * min(1, max(0, intensity))
        playTone(freq: 3000, freqEnd: 300, duration: 0.12, shape: .noise, gain: g)
        playTone(freq: 220, duration: 0.1, shape: .square, gain: g * 0.8)
    }

    func playBoost() {
        playTone(freq: 500, freqEnd: 1100, duration: 0.18, shape: .square, gain: 0.15)
    }

    func playSpecialMove() {
        playSequence([
            (220, 900, 0, 0.22, .sawtooth, 0.16), (440, 1400, 60, 0.24, .square, 0.16),
            (660, 1800, 140, 0.3, .square, 0.16),
        ])
        playTone(freq: 3200, freqEnd: 600, duration: 0.4, shape: .noise, gain: 0.14)
    }

    func playGaugeFull() {
        playSequence([(700, nil, 0, 0.08, .square, 0.12), (1000, nil, 70, 0.12, .square, 0.12)])
    }

    func playSpinOut() {
        playSequence([(260, 140, 0, 0.5, .sawtooth, 0.16)])
        playTone(freq: 1600, freqEnd: 200, duration: 0.5, shape: .noise, gain: 0.08)
    }

    func playRingOut() {
        playSequence([(500, 900, 0, 0.14, .square, 0.16), (700, 1200, 100, 0.18, .square, 0.16)])
    }

    func playBurst() {
        playTone(freq: 4000, freqEnd: 100, duration: 0.4, shape: .noise, gain: 0.22)
        playTone(freq: 80, duration: 0.4, shape: .sawtooth, gain: 0.2)
    }

    func playRoundWin() {
        playSequence([(523, nil, 0, 0.12, .square, 0.16), (659, nil, 100, 0.12, .square, 0.16), (784, nil, 200, 0.2, .square, 0.16)])
    }

    func playRoundLose() {
        playSequence([(392, nil, 0, 0.16, .sawtooth, 0.15), (330, nil, 140, 0.22, .sawtooth, 0.15)])
    }

    func playMatchWin() {
        playSequence([
            (523, nil, 0, 0.14, .square, 0.18), (659, nil, 120, 0.14, .square, 0.18),
            (784, nil, 240, 0.14, .square, 0.18), (1047, nil, 380, 0.35, .square, 0.18),
        ])
    }

    func playUITap() {
        playTone(freq: 700, duration: 0.05, shape: .square, gain: 0.1)
    }
}
