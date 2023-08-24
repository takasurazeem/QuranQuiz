//
//  PDFCreator.swift
//  QuranQuiz
//
//  Created by Takasur Azeem on 31/07/2023.
//

import PDFKit

class PDFGenerator {
    init(
        title: String,
        verses: [QuizVerse]
    ) {
        self.title = title
        self.verses = verses
//        print("verses.count: \(verses.count)")
    }
    
    
    func generateQuiz() -> Data {
        // 1
        let pdfMetaData = [
          kCGPDFContextCreator: "Quiz Builder",
          kCGPDFContextAuthor: "takasurazeem@gmail.com",
          kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2
        let pageWidth = 8.5 * 72.0
//        print("Page Width: \(pageWidth)")
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()
            // 6
            let openingAttributes = [
                NSAttributedString.Key.font: theOpeningFont
            ]
            
            let rightHeadingTextAttributes = [
                NSAttributedString.Key.font: leftRightHeadingsFont
            ]
            
            let belowOpeningTextAttributes = [
                NSAttributedString.Key.font: belowOpeningTextFont
            ]
            
            let nameAndDateTextAttributes = [
                NSAttributedString.Key.font: nameAndDateTextFont
            ]

            theOpeningText.draw(
                at: CGPoint(
                    x: (pageWidth) / 2 - theOpeningText.width(usingFont: theOpeningFont) / 2,
                    y: 5
                ),
                withAttributes: openingAttributes
            )
            let rightHeadingTextWidth = rightHeadingText.width(usingFont: leftRightHeadingsFont)
            rightHeadingText.draw(
                at: CGPoint(
                    x: pageWidth - rightHeadingTextWidth - (rightHeadingTextWidth * 0.1),
                    y: 5
                ),
                withAttributes: rightHeadingTextAttributes
            )
            leftHeadingText.draw(
                at: CGPoint(
                    x: 10,
                    y: 5
                ),
                withAttributes: rightHeadingTextAttributes
            )
            belowOpeningText.draw(
                at: CGPoint(
                    x: (pageWidth) / 2 - belowOpeningText.width(usingFont: belowOpeningTextFont) / 2,
                    y: theOpeningText.heightOfString(usingFont: theOpeningFont)
                ),
                withAttributes: belowOpeningTextAttributes
            )
            let studentNameTextWidth = studentNameText.width(usingFont: nameAndDateTextFont)
            studentNameText.draw(
                at: CGPoint(
                    x: pageWidth - studentNameTextWidth - (studentNameTextWidth * 0.1),
                    y: studentNameRowYPos
                ),
                withAttributes: nameAndDateTextAttributes
            )
            nameUnderScores.draw(
                at: CGPoint(
                    x: pageWidth - studentNameTextWidth - (nameUnderScores.width(usingFont: .boldSystemFont(ofSize: 14)) * 1.35),
                    y: studentNameRowYPos
                ),
                withAttributes: nameAndDateTextAttributes
            )
            dateText.draw(
                at: CGPoint(
                    x: dateTextXPos,
                    y: studentNameRowYPos
                ),
                withAttributes: nameAndDateTextAttributes
            )
            date.draw(
                at: CGPoint(
                    x: 15,
                    y: studentNameRowYPos
                ),
                withAttributes: nameAndDateTextAttributes
            )
            var yPos = studentNameRowYPos + 70
            for verse in verses {
                let nextPost = addVerseText(
                    verse: verse.text,
                    pageRect: pageRect,
                    textTop: yPos
                )
                yPos = nextPost
                
            }
        }
        
        return data
    }
    
    func addVerseText(
        verse: String,
        pageRect: CGRect,
        textTop: CGFloat
    ) -> CGFloat {
        let textFont = theOpeningFont//.withSize(22)
        // 1
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.lineBreakMode = .byWordWrapping
        // 2
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.writingDirection: [NSWritingDirection.rightToLeft.rawValue],
            NSAttributedString.Key.languageIdentifier: "ar_SA"
        ] as [NSAttributedString.Key : Any]
        let attributedText = NSAttributedString(
            string: verse,
            attributes: textAttributes
        )
        // 3
        let width = pageRect.width - 20
        let height = attributedText.height(containerWidth: width)
        let textRect = CGRect(
            x: 10,
            y: textTop,
            width: width,
            height: height
        )
        print(textRect)
        attributedText.draw(in: textRect)
        return textRect.maxY
    }

    
    // TODO: - Use AppStorage, some of these will be set from a settings menu for more flexibility in future ان شاء اللہ تَعَالٰی
    // MARK: - Fonts
    let theOpeningFont = UIFont(name: "_PDMS_Saleem_QuranFont", size: 24) ?? .boldSystemFont(ofSize: 64)
    let leftRightHeadingsFont = UIFont(name: "NotoNastaliqUrdu", size: 14) ?? .boldSystemFont(ofSize: 64)
    let belowOpeningTextFont = UIFont(name: "DiwaniBent", size: 28) ?? .boldSystemFont(ofSize: 64)
    let nameAndDateTextFont = UIFont(name: "NotoNastaliqUrdu", size: 18) ?? .boldSystemFont(ofSize: 64)
    
    // MARK: - Texts
    let theOpeningText = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ"
    let rightHeadingText = "امن ترجمةالقرآن کلاس"
    let leftHeadingText = "جامع مسجد امن واپڈا ٹاؤن گوجراںوالہ"
    let belowOpeningText = "سلسلہ وار ٹیسٹ"
    let studentNameText = "نام طالب علم:"
    let nameUnderScores = Array(repeating: "_", count: 20).reduce("", +)
    let dateText = "بتاریخ:"
    let translateFollowingAyahsText = "درج زیل آیات ترجمہ لکھیں:"
    
    
    private let title: String
    private let verses: [QuizVerse]
}

extension PDFGenerator {
    var studentNameRowYPos: CGFloat {
        belowOpeningText.heightOfString(usingFont: belowOpeningTextFont) + theOpeningText.heightOfString(usingFont: theOpeningFont)
    }
    
    var dateTextXPos: CGFloat {
        date.width(usingFont: nameAndDateTextFont) + 20
    }
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: Date())
        return formattedDate
    }
}

