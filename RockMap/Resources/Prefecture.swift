extension Resources {
    enum Prefecture: Identifiable, CaseIterable {

        // 北海道
        case hokkaido

        // 東北
        case aomori
        case iwate
        case miyagi
        case akita
        case yamagata
        case fukushima

        // 関東
        case ibaraki
        case tochigi
        case gunma
        case saitama
        case chiba
        case tokyo
        case kanagawa

        // 中部
        case niigata
        case toyama
        case ishikawa
        case fukui
        case yamanashi
        case nagano
        case gifu
        case shizuoka
        case aichi

        // 関西
        case mie
        case shiga
        case kyoto
        case osaka
        case hyogo
        case nara
        case wakayama

        // 中国
        case tottori
        case shimane
        case okayama
        case hiroshima
        case yamaguchi

        //　四国
        case tokushima
        case kagawa
        case ehime
        case kochi

        // 九州
        case fukuoka
        case saga
        case nagasaki
        case kumamoto
        case oita
        case miyazaki
        case kagoshima
        case okinawa


        var id: Self { self }

        var name: String {
            switch self {
                    // 北海道
                case .hokkaido: return "北海道"

                    // 東北
                case .aomori   : return "青森"
                case .iwate    : return "岩手"
                case .miyagi   : return "宮城"
                case .akita    : return "秋田"
                case .yamagata : return "山形"
                case .fukushima: return "福島"

                    // 関東
                case .ibaraki : return "茨城"
                case .tochigi : return "栃木"
                case .gunma   : return "群馬"
                case .saitama : return "埼玉"
                case .chiba   : return "千葉"
                case .tokyo   : return "東京"
                case .kanagawa: return "神奈川"

                    // 中部
                case .niigata  : return "新潟"
                case .toyama   : return "富山"
                case .ishikawa : return "石川"
                case .fukui    : return "福井"
                case .yamanashi: return "山梨"
                case .nagano   : return "長野"
                case .gifu     : return "岐阜"
                case .shizuoka : return "静岡"
                case .aichi    : return "愛知"

                    // 関西
                case .mie     : return "三重"
                case .shiga   : return "滋賀"
                case .kyoto   : return "京都"
                case .osaka   : return "大阪"
                case .hyogo   : return "兵庫"
                case .nara    : return "奈良"
                case .wakayama: return "和歌山"

                    // 中国
                case .tottori  : return "鳥取"
                case .shimane  : return "島根"
                case .okayama  : return "岡山"
                case .hiroshima: return "広島"
                case .yamaguchi: return "山口"

                    // 四国
                case .tokushima: return "徳島"
                case .kagawa   : return "香川"
                case .ehime    : return "愛媛"
                case .kochi    : return "高知"

                    // 九州
                case .fukuoka  : return "福岡"
                case .saga     : return "佐賀"
                case .nagasaki : return "長崎"
                case .kumamoto : return "熊本"
                case .oita     : return "大分"
                case .miyazaki : return "宮崎"
                case .kagoshima: return "鹿児島"
                case .okinawa  : return "沖縄"
            }
        }

        var nameWithSuffix: String {
            switch self {
                case .hokkaido:
                    return self.name

                default:
                    return self.name + self.suffix
            }
        }

        var suffix: String {
            switch self {
                case .hokkaido     : return "道"
                case .tokyo        : return "都"
                case .kyoto, .osaka: return "府"
                default            : return "県"
            }
        }
    }
}
