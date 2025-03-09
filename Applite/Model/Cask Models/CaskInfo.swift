//
//  CaskInfo.swift
//  Applite
//
//  Created by Milán Várady on 2024.12.29.
//

import Foundation

/// Holds all static information of a cask
struct CaskInfo: Codable {
    /// Unique id of the class, this is the same name you would use to download the cask with brew
    let token: String
    let fullToken: String
    let tap: String
    /// Longer format cask name
    let name: String
    /// Short description
    let description: String
    let homepageURL: URL?
    /// If true app has pkg artifacts
    let pkgInstaller: Bool
    /// If true app has script installer artifacts
    let scriptInstaller: Bool
    /// If true app has manual installer artifacts
    let manualInstaller: Bool
    let warning: CaskWarning?

    /// Initialize from a ``CaskDTO`` data transfer object
    init(from decoder: Decoder) throws {
        let rawData = try CaskDTO(from: decoder)

        self.token = rawData.token
        self.fullToken = rawData.fullToken
        self.tap = rawData.tap
        self.name = rawData.nameArray[safeIndex: 0] ?? "N/A"
        self.description = rawData.desc ?? "N/A"
        self.homepageURL = URL(string: rawData.homepage)
        self.pkgInstaller = rawData.artifacts.contains {
            switch $0 {
            case .known(type: .pkg, args: _): true
            default: false
            }
        }
        self.scriptInstaller = rawData.artifacts.contains {
            switch $0 {
            case .known(type: .installer, args: .array(let args)):
                if case .object(let argument) = args.first,
                   case (key: "script", value: _)? = argument.first {
                    true
                } else {
                    false
                }
            default: false
            }
        }
        self.manualInstaller = rawData.artifacts.contains {
            switch $0 {
            case .known(type: .installer, args: .array(let args)):
                if case .object(let argument) = args.first,
                   case (key: "manual", value: .string(_))? = argument.first {
                    true
                } else {
                    false
                }
            default: false
            }
        }

        if rawData.disabled {
            self.warning = .disabled(date: rawData.disableDate ?? "N/A", reason: rawData.disableReason ?? "N/A")
        } else if rawData.deprecated {
            self.warning = .deprecated(date: rawData.deprecationDate ?? "N/A", reason: rawData.deprecationReason ?? "N/A")
        } else if let caveat = rawData.caveats {
            self.warning = .hasCaveat(caveat: caveat)
        } else {
            self.warning = nil
        }
    }

    init(token: String, fullToken: String, tap: String, name: String, description: String, homepageURL: URL?, pkgInstaller: Bool, scriptInstaller: Bool, manualInstaller: Bool, warning: CaskWarning?) {
        self.token = token
        self.fullToken = fullToken
        self.tap = tap
        self.name = name
        self.description = description
        self.homepageURL = homepageURL
        self.pkgInstaller = pkgInstaller
        self.scriptInstaller = scriptInstaller
        self.manualInstaller = manualInstaller
        self.warning = warning
    }
}
