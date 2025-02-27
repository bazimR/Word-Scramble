//
//  ContentView.swift
//  Word Scramble
//
//  Created by Rishal Bazim on 18/02/25.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord: String = ""
    @State private var rootWord: String = ""
    @State private var usedWords: [String] = [String]()

    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var errorShow: Bool = false

    @State private var userScore: Int = 0
    @State private var userRound: Int = 1
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section {
                    HStack {
                        Text("Round :")
                        Text("\(userRound)").font(.headline)
                        Spacer()
                        Text("Score :")
                        Text("\(userScore)").font(.headline)
                    }
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.navigationTitle(rootWord).onSubmit {
                addNewWord()
            }.onAppear(perform: startGame).alert(
                errorTitle, isPresented: $errorShow
            ) {
            } message: {
                Text(errorMessage)
            }.toolbar {
                Button("Change word") {
                    withAnimation {
                        usedWords.removeAll()
                        userRound += 1
                    }
                    startGame()
                }
            }
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard answer.count > 0 else {
            return
        }
        guard isWordShort(word: answer) else {
            wordError(
                title: "Word is too short",
                message: "Word should atleast 3 characters.")
            return
        }
        guard !isWordSameAsRootWord(word: answer) else {
            wordError(
                title: "Word is same as \(rootWord)",
                message: "Word cant be same as original word!")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(
                title: "Word not possible",
                message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isRealWord(word: answer) else {
            wordError(
                title: "Word not recognized",
                message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWords.insert(newWord, at: 0)
            userScore += 1
        }
        newWord = ""
    }

    func startGame() {
        if let startWordUrl = Bundle.main.url(
            forResource: "start", withExtension: "txt")
        {
            if let startWord = try? String(
                contentsOf: startWordUrl,
                encoding: .utf8
            ) {
                let allWords = startWord.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "airplane"

                return
            }
        }
        fatalError("Failed load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isRealWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )

        return misspelledRange.location == NSNotFound
    }

    func isWordShort(word: String) -> Bool {
        word.count > 2
    }

    func isWordSameAsRootWord(word: String) -> Bool {
        let originalWord = rootWord
        if originalWord == word {
            return true
        }
        return false
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        errorShow = true
    }
}

#Preview {
    ContentView()
}
