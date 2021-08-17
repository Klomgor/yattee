import SwiftUI

struct TrendingCountrySelection: View {
    static let prompt = "Country Name or Code"
    @Binding var selectedCountry: Country?

    @ObservedObject private var store = Store(Country.allCases)

    @State private var query: String = ""
    @State private var selection: Country?

    @FocusState var countryIsFocused
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            #if os(macOS)
                HStack {
                    TextField("Country", text: $query, prompt: Text(TrendingCountrySelection.prompt))
                        .focused($countryIsFocused)

                    Button("Done") { selectCountryAndDismiss() }
                        .keyboardShortcut(.defaultAction)
                        .keyboardShortcut(.cancelAction)
                }
                .padding([.horizontal, .top])

                countriesList
            #else
                NavigationView {
                    countriesList
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button("Done") { selectCountryAndDismiss() }
                            }
                        }
                    #if os(iOS)
                        .navigationBarTitle("Trending Country", displayMode: .automatic)
                    #endif
                }
            #endif
        }
        .onAppear {
            countryIsFocused = true
        }
        .onSubmit { selectCountryAndDismiss() }
        #if !os(macOS)
            .searchable(text: $query, placement: searchPlacement, prompt: Text(TrendingCountrySelection.prompt))
        #endif
        #if os(tvOS)
            .background(.thinMaterial)
        #endif
    }

    var countriesList: some View {
        ScrollViewReader { _ in
            List(store.collection, selection: $selection) { country in
                #if os(macOS)
                    Text(country.name)
                        .tag(country)
                        .id(country)
                #else
                    Button(country.name) { selectCountryAndDismiss(country) }
                #endif
            }
            .onChange(of: query) { newQuery in
                let results = Country.search(newQuery)
                store.replace(results)

                selection = results.first
            }
        }

        #if os(macOS)
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .padding(.bottom, 5)

        #endif
    }

    var searchPlacement: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .automatic
        #endif
    }

    func selectCountryAndDismiss(_ country: Country? = nil) {
        let selected = country ?? selection

        if selected != nil {
            selectedCountry = selected
        }

        dismiss()
    }
}

struct TrendingCountrySelection_Previews: PreviewProvider {
    static var previews: some View {
        TrendingCountrySelection(selectedCountry: .constant(.pl))
    }
}