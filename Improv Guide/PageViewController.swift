//
//  PageViewController.swift
//  Improv Guide
//
//  Created by Ignat Remizov on 12/14/15.
//  Copyright © 2015 Ignat Remizov. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet var instructions: UITextView!
    @IBOutlet var instructionHeight: NSLayoutConstraint!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    
    @objc @IBOutlet weak var dataSource: PageControllerDataSource? {
        didSet {
            if dataSource != nil {
                rightButton.hidden = !dataSource!.pageShouldPresentRightArrow(self)
                leftButton.hidden = !dataSource!.pageShouldPresentLeftArrow(self)
                instructions.attributedText = NSMutableAttributedString(string: (dataSource?.instructionForPage(self))!, attributes: bodyAttributes)
                let linkAttributes = bodyAttributes + [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                if let random = dataSource?.previousRandomsForPage(self) {
                    var endString:String
                    var appendedRandom = NSMutableAttributedString()
                    if random.isEmpty {
                        endString = "Generate here"
                        appendedRandom = NSMutableAttributedString(string: endString, attributes: linkAttributes + [NSLinkAttributeName: "0"])
                    }
                    let attributedInstructions = NSMutableAttributedString(attributedString: instructions.attributedText)
                    if !random.isEmpty {
                        if dataSource!.titleForPage(self).containsString("Good Cop, Bad Cop") {
                            for (index, word) in random.enumerate() {
                                switch index {
                                case 0:
                                    appendedRandom.appendAttributedString(NSAttributedString(string: "The criminal committed ", attributes: bodyAttributes))
                                case 1:
                                    appendedRandom.appendAttributedString(NSAttributedString(string: " with ", attributes: bodyAttributes))
                                case 2:
                                    appendedRandom.appendAttributedString(NSAttributedString(string: " in ", attributes: bodyAttributes))
                                default:
                                    break
                                }
                                appendedRandom.appendAttributedString(NSAttributedString(string: word, attributes: linkAttributes + [NSLinkAttributeName: "\(index)"]))
                            }
                        } else {
                            for (index, word) in random.enumerate() {
                                appendedRandom.appendAttributedString(NSAttributedString(string: word, attributes: linkAttributes + [NSLinkAttributeName: "\(index)"]))
                            }
                        }
                    }
                    instructions.attributedText = attributedInstructions + "\n" + appendedRandom
                }
            }
        }
    }
    
    let paragraphStyle = NSMutableParagraphStyle()
    var step:Int = 0 
    
    private var bodyAttributes:[String:AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paragraphStyle.alignment = .Center
        bodyAttributes = [NSFontAttributeName:UIFont.systemFontOfSize(30), NSParagraphStyleAttributeName: paragraphStyle]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        instructions.sizeToFit()
        instructionHeight.constant = instructions.frame.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        instructions.sizeToFit()
    }
    
    
    @IBAction func goBack(sender:UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        instructionHeight.constant = instructions.size
//    }

}

extension PageViewController:UITextViewDelegate {
    
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if dataSource?.previousRandomsForPage(self) != nil {
            let generatedWords = dataSource!.previousRandomsForPage(self)
            var randomString = dataSource!.randomElementForPage(self, atIndex: Int(URL.absoluteString)!) ?? ""
            let range = NSString(string:textView.attributedText.string).rangeOfString(dataSource!.instructionForPage(self))
            let instructionText = textView.attributedText[range]
            let linkAttributes = bodyAttributes + [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            var attributedRandomString = NSMutableAttributedString()
            let isCopGame = dataSource!.titleForPage(self).containsString("Good Cop, Bad Cop")
            if generatedWords != nil && !generatedWords!.isEmpty {
                while randomString == generatedWords![Int(URL.absoluteString)!] {
                    randomString = dataSource!.randomElementForPage(self, atIndex: Int(URL.absoluteString)!) ?? ""
                }
            }
            if generatedWords?.count > 1 {
                for (index, word) in generatedWords!.enumerate() {
                    let attributedWord:NSAttributedString
                    if isCopGame {
                        switch index {
                        case 0:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: "The criminal committed ", attributes: bodyAttributes))
                        case 1:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: " with ", attributes: bodyAttributes))
                        case 2:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: " in ", attributes: bodyAttributes))
                        default:
                            break
                        }
                    }
                    if index == Int(URL.absoluteString)! {
                        attributedWord = NSAttributedString(string: randomString, attributes: linkAttributes + [NSLinkAttributeName: "\(index)"])
                    } else {
                        attributedWord = NSAttributedString(string: word, attributes: linkAttributes + [NSLinkAttributeName:"\(index)"])
                    }
                    attributedRandomString.appendAttributedString(attributedWord)
                    if !isCopGame && index < generatedWords!.count - 1 {
                        attributedRandomString.appendAttributedString(NSAttributedString(string: "\n", attributes: bodyAttributes))
                    }
                }
            } else {
                if isCopGame {
                    for index in 0...2 {
                        switch index {
                        case 0:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: "The criminal committed ", attributes: bodyAttributes))
                        case 1:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: " with ", attributes: bodyAttributes))
                        case 2:
                            attributedRandomString.appendAttributedString(NSAttributedString(string: " in ", attributes: bodyAttributes))
                            
                        default:
                            break
                        }
                        attributedRandomString.appendAttributedString(NSAttributedString(string: (dataSource?.randomElementForPage(self, atIndex: index))!, attributes: linkAttributes + [NSLinkAttributeName: "\(index)"]))
                    }
                } else {
                    attributedRandomString = NSMutableAttributedString(string: randomString, attributes: linkAttributes + [NSLinkAttributeName: "0"])
                }
            }
            textView.attributedText = instructionText + "\n" + attributedRandomString
            textView.sizeToFit()
            instructionHeight.constant = textView.frame.height
            textView.setNeedsLayout()
        }
        return false
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if textView.selectedRange.length != 0 {
            textView.selectedRange = NSRange(location: 0, length: 0)
        }
    }
}


@objc protocol PageControllerDataSource:NSObjectProtocol {
    func instructionForPage(pageController: PageViewController) -> String
    func titleForPage(pageController: PageViewController) -> String
    func randomElementForPage(pageController: PageViewController, atIndex index:Int) -> String
    func previousRandomsForPage(pageController: PageViewController) -> [String]?
    func randomTypesForPage(pageController: PageViewController) -> [String]
    func pageShouldPresentRightArrow(pageController: PageViewController) -> Bool
    func pageShouldPresentLeftArrow(pageController: PageViewController) -> Bool
}
