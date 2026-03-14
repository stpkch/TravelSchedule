import Foundation

enum MockData {

    static let cities: [City] = [
        City(
            name: "Москва",
            stations: [
                Station(name: "Киевский вокзал"),
                Station(name: "Курский вокзал"),
                Station(name: "Ярославский вокзал"),
                Station(name: "Белорусский вокзал"),
                Station(name: "Савеловский вокзал"),
                Station(name: "Ленинградский вокзал")
            ]
        ),
        City(
            name: "Санкт-Петербург",
            stations: [
                Station(name: "Балтийский вокзал"),
                Station(name: "Московский вокзал"),
                Station(name: "Ладожский вокзал"),
                Station(name: "Витебский вокзал")
            ]
        ),
        City(
            name: "Сочи",
            stations: [
                Station(name: "Сочи"),
                Station(name: "Адлер"),
                Station(name: "Хоста")
            ]
        ),
        City(
            name: "Краснодар",
            stations: [
                Station(name: "Краснодар-1"),
                Station(name: "Краснодар-2")
            ]
        ),
        City(
            name: "Казань",
            stations: [
                Station(name: "Казань-Пасс."),
                Station(name: "Восстание-Пассажирская")
            ]
        ),
        City(
            name: "Омск",
            stations: [
                Station(name: "Омск-Пассажирский")
            ]
        ),
        City(
            name: "Горный воздух",
            stations: [
                Station(name: "Горный воздух")
            ]
        )
    ]

    static let stories: [Story] = [
        Story(title: "Text Text Text Text...", imageName: "story1"),
        Story(title: "Text Text Text Text...", imageName: "story2"),
        Story(title: "Text Text Text Text...", imageName: "story3"),
        Story(title: "Text Text Text Text...", imageName: "story4")
    ]

    static let carriers: [Carrier] = [
        Carrier(
            name: "РЖД",
            logoAssetName: "RZD",
            transferInfo: "С пересадкой в Костроме",
            departureTime: "22:30",
            arrivalTime: "08:15",
            duration: "20 часов",
            dateText: "14 января"
        ),
        Carrier(
            name: "ФГК",
            logoAssetName: "FGK",
            transferInfo: nil,
            departureTime: "01:15",
            arrivalTime: "09:00",
            duration: "9 часов",
            dateText: "15 января"
        ),
        Carrier(
            name: "Урал логистика",
            logoAssetName: "URAL",
            transferInfo: nil,
            departureTime: "12:30",
            arrivalTime: "21:00",
            duration: "9 часов",
            dateText: "16 января"
        ),
        Carrier(
            name: "РЖД",
            logoAssetName: "RZD",
            transferInfo: "С пересадкой в Костроме",
            departureTime: "22:30",
            arrivalTime: "08:15",
            duration: "20 часов",
            dateText: "17 января"
        ),
        Carrier(
            name: "РЖД",
            logoAssetName: "RZD",
            transferInfo: "С пересадкой в Костроме",
            departureTime: "22:30",
            arrivalTime: "08:15",
            duration: "20 часов",
            dateText: "17 января"
        )
    ]
}
