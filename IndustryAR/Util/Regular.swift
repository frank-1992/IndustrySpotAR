//
//  SSRegular.swift
//  Scene
//
//  Created by  吴 熠 on 2021/11/8.
//

import UIKit

class Regular: NSObject {

}

enum ValidatedType {
    case email
    case phoneNumber
    case number
    case specificNumbers
    case chinese
    case illegalCharacter
    case url
    case blankLines
    case qq
    case id
    case mac
    case idCard
    case dateInformation
    case accountLegal
    case password
    case strongPassword
    case thereIsNo
}

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
func validateText(validatedType type: ValidatedType, validateString: String) -> Bool {
    do {
        let pattern: String

        switch type {

        case ValidatedType.email:
            pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,8})$"

        case ValidatedType.phoneNumber:
            pattern = "^1[0-9]{10}$"

        case ValidatedType.number:
            pattern = "^[0-9]*$"

        case ValidatedType.specificNumbers:
            pattern = "^\\d{n}$"

        case ValidatedType.chinese:
            pattern = "^[\\u4e00-\\u9fa5]{0,}$"

        case ValidatedType.illegalCharacter:
            pattern = "[%&',;=?$\\\\^]+"

        case ValidatedType.url:
            pattern = "^http://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"

        case ValidatedType.blankLines:
            pattern = "^s*|s*$"

        case ValidatedType.qq:
            pattern = "[1-9][0-9]{4,}"

        case ValidatedType.id:
            pattern = "([1-9]{1,3}\\.){3}[1-9]"

        case ValidatedType.mac:
            pattern = "([A-Fa-f0-9]{2}\\:){5}[A-Fa-f0-9]"

        case ValidatedType.idCard:
            pattern = "\\d{14}[[0-9],0-9xX]"

        case ValidatedType.dateInformation:
            pattern = "^\\d{4}-\\d{1,2}-\\d{1,2}"

        case ValidatedType.accountLegal:
            pattern = "^[a-zA-Z][a-zA-Z0-9_]{4,15}$"

        case ValidatedType.password:
            pattern = "^[a-zA-Z]\\w{5,17}$"

        case ValidatedType.strongPassword:
            pattern = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$"

        default:
        pattern = ""
        }

        let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: validateString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(location: 0, length: validateString.count))
        return !matches.isEmpty
    } catch {
        return false
    }
}

/*
 * 验证邮箱
 */

func emailIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.email, validateString: vStr)
}

/*
 * 验证手机号
 */
func phoneNumberIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.phoneNumber, validateString: vStr)
}

/*
 * 验证只能输入数字
 */
func numberIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.number, validateString: vStr)
}

/*
 * 验证输入几位数字   里面的n换成你想要的数字
 */
func specificNumbersIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.specificNumbers, validateString: vStr)
}

/*
 * 验证是否是中文
 */
func chineseIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.chinese, validateString: vStr)
}

/*
 * 验证是否含有^%&',;=?$\"等字符
 */
func illegalCharacterIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.illegalCharacter, validateString: vStr)
}

/*
 * 验证URL
 */
func urlIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.url, validateString: vStr)
}

/*
 * 验证首尾空白行          这个现在有问题
 */
func blankLinesIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.blankLines, validateString: vStr)
}

/*
 * 验证QQ号
 */
func qqIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.qq, validateString: vStr)
}

/*
 * 验证ID地址
 */
func idIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.id, validateString: vStr)
}

/*
 * 验证MAC地址
 */
func macIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.mac, validateString: vStr)
}

/*
 * 验证身份证号
 */
func idCardIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.idCard, validateString: vStr)
}

/*
 * 验证年月日    例子 2013-04-12
 */
func dateInformationIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.dateInformation, validateString: vStr)
}

/*
 * 验证帐号是否合法(字母开头，允许5-16字节，允许字母数字下划线)
 */
func accountLegalIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.accountLegal, validateString: vStr)
}
/*
 * 验证密码(以字母开头，长度在6~18之间，只能包含字母、数字和下划线)
 */
func passwordIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.password, validateString: vStr)
}
/*
 * 验证强密码(必须包含大小写字母和数字的组合，不能使用特殊字符，长度在8-10之间)
 */
func strongPasswordIsValidated(vStr: String) -> Bool {
    return validateText(validatedType: ValidatedType.strongPassword, validateString: vStr)
}
