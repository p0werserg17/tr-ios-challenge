import SwiftUI

struct FiltersSheet: View {
    @Binding var sort: SortOption
    @Binding var layout: LayoutMode
    let onApply: () -> Void

    // Defaults for Reset
    private let defaultSort: SortOption = .titleAZ
    private let defaultLayout: LayoutMode = .grid

    @State private var stagedSort: SortOption
    @State private var stagedLayout: LayoutMode

    init(sort: Binding<SortOption>, layout: Binding<LayoutMode>, onApply: @escaping () -> Void) {
        _sort = sort
        _layout = layout
        self.onApply = onApply
        _stagedSort = State(initialValue: sort.wrappedValue)
        _stagedLayout = State(initialValue: layout.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content
                Form {
                    Section("Sort by") {
                        Picker("Sort", selection: $stagedSort) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    }
                    Section("Layout") {
                        Picker("Layout", selection: $stagedLayout) {
                            Text("Grid").tag(LayoutMode.grid)
                            Text("List").tag(LayoutMode.list)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .scrollContentBackground(.automatic)

                // Bottom bar: two full-width buttons
                VStack(spacing: 12) {
                    Divider()
                    HStack(spacing: 12) {
                        Button {
                            stagedSort = defaultSort
                            stagedLayout = defaultLayout
                        } label: {
                            Text("Reset")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)

                        Button {
                            // Commit & notify
                            sort = stagedSort
                            layout = stagedLayout
                            onApply()
                        } label: {
                            Text("Apply")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .padding(.top, 4)
                    .background(.bar)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(20)
    }
}
