import Foundation
import Postbox
import SwiftSignalKit

public struct ExperimentalSettings: PreferencesEntry, Equatable {
    public var enableFeed: Bool
    
    public static var defaultSettings: ExperimentalSettings {
        return ExperimentalSettings(decoder: PostboxDecoder(buffer: MemoryBuffer()))
    }
    
    public init(enableFeed: Bool) {
        self.enableFeed = enableFeed
    }
    
    public init(decoder: PostboxDecoder) {
        self.enableFeed = decoder.decodeInt32ForKey("enableFeed", orElse: 0) != 0
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.enableFeed ? 1 : 0, forKey: "enableFeed")
    }
    
    public func isEqual(to: PreferencesEntry) -> Bool {
        if let to = to as? ExperimentalSettings {
            return self == to
        } else {
            return false
        }
    }
    
    public static func ==(lhs: ExperimentalSettings, rhs: ExperimentalSettings) -> Bool {
        return lhs.enableFeed == rhs.enableFeed
    }
}

func updateExperimentalSettingsInteractively(postbox: Postbox, _ f: @escaping (ExperimentalSettings) -> ExperimentalSettings) -> Signal<Void, NoError> {
    return postbox.transaction { transaction -> Void in
        transaction.updatePreferencesEntry(key: ApplicationSpecificPreferencesKeys.callListSettings, { entry in
            let currentSettings: ExperimentalSettings
            if let entry = entry as? ExperimentalSettings {
                currentSettings = entry
            } else {
                currentSettings = ExperimentalSettings.defaultSettings
            }
            return f(currentSettings)
        })
    }
}
