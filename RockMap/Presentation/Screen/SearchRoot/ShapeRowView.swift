import SwiftUI

struct ShapeRowView: View {

    @Binding var selectedShapes: [Entity.Course.Shape]

    var body: some View {
        HStack {
            Text("形状")
            Spacer()
            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .trailing) {
                ForEach(Entity.Course.Shape.allCases) { shape in
                    Button {
                        if selectedShapes.contains(shape) {

                            guard let index = selectedShapes.firstIndex(of: shape) else {
                                return
                            }

                            selectedShapes.remove(at: index)
                        } else {
                            selectedShapes.append(shape)
                        }

                    } label: {
                        Text(shape.name).font(.callout)
                    }
                    .foregroundColor(
                        selectedShapes.contains(shape)
                        ? Color(uiColor: UIColor.Pallete.primaryGreen)
                        : Color.gray
                    )
                    .padding(4)
                    .buttonStyle(PlainButtonStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                selectedShapes.contains(shape)
                                ? Color(uiColor: UIColor.Pallete.primaryGreen)
                                : Color.gray,
                                lineWidth: selectedShapes.contains(shape)
                                ? 1
                                : 0.5
                            )
                    )
                }
            }
        }
    }
}

struct ShapeRowView_Previews: PreviewProvider {
    static var previews: some View {
        ShapeRowView(selectedShapes: .constant([]))
    }
}
