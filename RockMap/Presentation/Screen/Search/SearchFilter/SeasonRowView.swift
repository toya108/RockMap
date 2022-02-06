import SwiftUI

struct SeasonRowView: View {

    @Binding var selectedSeasons: [Entity.Rock.Season]

    var body: some View {
        HStack {
            Text("シーズン")
            Spacer()
            HStack(spacing: 4) {
                ForEach(Entity.Rock.Season.allCases) { season in
                    Button {
                        if selectedSeasons.contains(season) {

                            guard let index = selectedSeasons.firstIndex(of: season) else {
                                return
                            }

                            selectedSeasons.remove(at: index)
                        } else {
                            selectedSeasons.append(season)
                        }

                    } label: {
                        HStack {
                            season.icon.resizable().frame(maxWidth: 20, maxHeight: 20)
                            Text(season.name).font(.callout)
                        }
                    }
                    .foregroundColor(
                        selectedSeasons.contains(season)
                        ? Color(uiColor: UIColor.Pallete.primaryGreen)
                        : Color.gray
                    )
                    .padding(4)
                    .buttonStyle(PlainButtonStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                selectedSeasons.contains(season)
                                ? Color(uiColor: UIColor.Pallete.primaryGreen)
                                : Color.gray,
                                lineWidth: selectedSeasons.contains(season)
                                ? 1
                                : 0.5
                            )
                    )
                }
            }
        }
    }
}

struct SeasonRowView_Previews: PreviewProvider {
    static var previews: some View {
        SeasonRowView(selectedSeasons: .constant([]))
    }
}
