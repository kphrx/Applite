//
//  CaskDTO.swift
//  Applite
//
//  Created by Milán Várady on 2022. 11. 04..
//

import Foundation

/// Intermediate Data Transfer Object (DTO) to load in cask information.
/// Data from the json file is loaded into this object first and later passed into a ``Cask`` object
struct CaskDTO: Decodable {
    let token: String
    let fullToken: String
    let tap: String
    let nameArray: Array<String>
    let desc: String?
    let homepage: String
    let caveats: String?
    let url: String
    let artifacts: Array<Artifact>
    let deprecated: Bool
    let deprecationDate: String?
    let deprecationReason: String?
    let disabled: Bool
    let disableDate: String?
    let disableReason: String?

    enum CodingKeys: String, CodingKey {
        case token
        case fullToken = "full_token"
        case tap
        case nameArray = "name"
        case desc
        case homepage
        case caveats
        case url
        case artifacts
        case deprecated
        case deprecationDate = "deprecation_date"
        case deprecationReason = "deprecation_reason"
        case disabled
        case disableDate = "disable_date"
        case disableReason = "disable_reason"
    }

    enum Artifact: Decodable {
        case known(type: CodingKeys, args: Arguments)
        case unknown(type: String, args: Arguments)

        enum CodingKeys: String, CodingKey {
            // ordinary artifact classes
            case installer
            case app
            case artifact
            case audioUnit = "audio_unit"
            case binary
            case colorpicker
            case dictionary
            case font
            case inputMethod = "input_method"
            case internetPlugin = "internet_plugin"
            case keyboardLayout = "keyboard_layout"
            case manpage
            case pkg
            case prefpane
            case qlplugin
            case mdimporter
            case screenSaver = "screen_saver"
            case service
            case stageOnly = "stage_only"
            case suite
            case vstPlugin = "vst_plugin"
            case vst3Plugin = "vst3_plugin"
            case zshCompletion = "zsh_completion"
            case fishCompletion = "fish_completion"
            case bashCompletion = "bash_completion"
            case uninstall
            case zap

            // artifact block classes
            case preflight
            case uninstallPreflight = "uninstall_preflight"
            case postflight
            case uninstallPostflight = "uninstall_postflight"
        }

        enum Arguments: Decodable {
            case null
            case array(Array<Argument>)

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()

                self = if container.decodeNil() {
                    .null
                } else {
                    .array(try container.decode(Array<Argument>.self))
                }
            }
        }

        enum Argument: Decodable {
            case string(String)
            case integer(Int)
            case float(Double)
            case boolean(Bool)
            case null
            case array(Array<Argument>)
            case object(Dictionary<String, Argument>)

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()

                self = if container.decodeNil() {
                    .null
                } else if let value = try? container.decode(String.self) {
                    .string(value)
                } else if let value = try? container.decode(Int.self) {
                    .integer(value)
                } else if let value = try? container.decode(Double.self) {
                    .float(value)
                } else if let value = try? container.decode(Bool.self) {
                    .boolean(value)
                } else if let value = try? container.decode(Array<Argument>.self) {
                    .array(value)
                } else {
                    .object(try container.decode(Dictionary<String, Argument>.self))
                }
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let artifactType = container.allKeys.first else {
                let artifact = try decoder.singleValueContainer().decode(Dictionary<String, Arguments>.self)
                let (key: artifactType, value: args) = artifact.first ?? ("unknown", .null)
                self = .unknown(type: artifactType, args: args)
                return
            }
            self = .known(type: artifactType, args: try container.decode(Arguments.self, forKey: artifactType))
        }
    }
}
