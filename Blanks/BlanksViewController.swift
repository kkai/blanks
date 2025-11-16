//
//  BlanksViewController.swift
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit
import QuartzCore

class BlanksViewController: UIViewController, OptionsViewControllerDelegate, UIGestureRecognizerDelegate {

    // MARK: - Properties

    var wordModel: WordModel!
    var isTapping = false

    @IBOutlet weak var wordButton1: UIButton!
    @IBOutlet weak var wordButton2: UIButton!
    @IBOutlet weak var wordButton3: UIButton!
    @IBOutlet weak var wordButton4: UIButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var gapLabel: UILabel!
    @IBOutlet weak var definitionTV: UITextView!
    @IBOutlet weak var tickView: UIImageView!
    @IBOutlet weak var crossView: UIImageView!

    private var word1: WordView!
    private var word2: WordView!
    private var word3: WordView!
    private var word4: WordView!

    private let gameStats = GameStats()

    private var selected: String = ""
    private var correct = false

    // MARK: - Constants

    private let growAnimationDuration = 0.15
    private let shrinkAnimationDuration = 0.15

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        wordModel = WordModel()

        let words = wordModel.getWords()

        // Load word views from XIB
        word1 = loadWordView()
        word2 = loadWordView()
        word3 = loadWordView()
        word4 = loadWordView()

        // Set button titles and word view text
        wordButton1.setTitle(words[0], for: .normal)
        wordButton2.setTitle(words[1], for: .normal)
        wordButton3.setTitle(words[2], for: .normal)
        wordButton4.setTitle(words[3], for: .normal)
        definitionTV.text = wordModel.definition

        word1.addWord(words[0])
        word2.addWord(words[1])
        word3.addWord(words[2])
        word4.addWord(words[3])

        score.text = gameStats.displayString
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let defaults = UserDefaults.standard
        if defaults.object(forKey: .tappingUI) != nil {
            isTapping = defaults.bool(forKey: .tappingUI)
        } else {
            defaults.set(false, forKey: .tappingUI)
            isTapping = false
        }

        if !isTapping {
            addGestureRecognizers(to: word1)
            addGestureRecognizers(to: word2)
            addGestureRecognizers(to: word3)
            addGestureRecognizers(to: word4)

            word1.isHidden = false
            word2.isHidden = false
            word3.isHidden = false
            word4.isHidden = false

            wordButton1.isHidden = true
            wordButton2.isHidden = true
            wordButton3.isHidden = true
            wordButton4.isHidden = true
        } else {
            word1.isHidden = true
            word2.isHidden = true
            word3.isHidden = true
            word4.isHidden = true

            wordButton1.isHidden = false
            wordButton2.isHidden = false
            wordButton3.isHidden = false
            wordButton4.isHidden = false
        }

        word1.frame = wordButton1.frame
        word2.frame = wordButton2.frame
        word3.frame = wordButton3.frame
        word4.frame = wordButton4.frame

        view.addSubview(word1)
        view.addSubview(word2)
        view.addSubview(word3)
        view.addSubview(word4)
    }

    // MARK: - Check Answer

    @IBAction func answerPressed(_ sender: Any) {
        if isTapping {
            guard let button = sender as? UIButton,
                  let titleText = button.titleLabel?.text else { return }

            selected = titleText
            checkAnswerAndShowResult()
        }
    }

    private func animateCorrectWrongView(_ selectedView: UIImageView) {
        UIView.animate(withDuration: 0.6, animations: {
            let transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            selectedView.transform = transform
        }, completion: { _ in
            self.grow3AnimationDidStop()
        })
    }

    // MARK: - Option View

    func optionsViewControllerDidFinish(_ controller: OptionsViewController) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showAlternate.rawValue {
            if let destination = segue.destination as? OptionsViewController {
                destination.delegate = self
            }
        }
    }

    // MARK: - Handling Touch

    // adds a set of gesture recognizers to one of our piece subviews
    private func addGestureRecognizers(to piece: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        piece.addGestureRecognizer(panGesture)
    }

    // shift the piece's center by the pan amount
    // reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
    @objc func panPiece(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let piece = gestureRecognizer.view else { return }

        adjustAnchorPoint(for: gestureRecognizer)

        if gestureRecognizer.state == .began {
            view.bringSubviewToFront(piece)
            let locationInSuperview = gestureRecognizer.location(in: piece.superview)
            if let wordView = piece as? WordView {
                animateFirstTouch(at: locationInSuperview, on: wordView)
            }
        }

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: piece.superview)
            piece.center = CGPoint(x: piece.center.x + translation.x, y: piece.center.y + translation.y)
            gestureRecognizer.setTranslation(.zero, in: piece.superview)
        }

        if gestureRecognizer.state == .ended {
            if piece.center.y <= 110 {
                if let wordView = piece as? WordView {
                    animateWord(toPlace: wordView)
                }
            }
            piece.transform = .identity
        }
    }

    // scale and rotation transforms are applied relative to the layer's anchor point
    // this method moves a gesture recognizer's view's anchor point between the user's fingers
    private func adjustAnchorPoint(for gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            guard let piece = gestureRecognizer.view else { return }
            let locationInSuperview = gestureRecognizer.location(in: piece.superview)
            piece.center = locationInSuperview
        }
    }

    private func animateFirstTouch(at touchPoint: CGPoint, on selectedView: WordView) {
        UIView.animate(withDuration: growAnimationDuration, animations: {
            let transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            selectedView.transform = transform
        }, completion: { _ in
            self.growAnimationDidStop()
        })

        UIView.animate(withDuration: growAnimationDuration + shrinkAnimationDuration) {
            selectedView.center = touchPoint
        }
    }

    private func growAnimationDidStop() {
        UIView.animate(withDuration: shrinkAnimationDuration) {
            // Animation completion
        }
    }

    private func animationDidStop(_ theAnimation: CAAnimation, finished flag: Bool) {
        checkAnswerAndShowResult()
    }

    private func checkAnswerAndShowResult() {
        let result: UIImageView

        if selected == wordModel.correct {
            correct = true
            result = tickView
            gameStats.recordCorrectAnswer()
        } else {
            correct = false
            result = crossView
            gameStats.recordWrongAnswer()
        }

        result.isHidden = false
        animateCorrectWrongView(result)
    }

    private func grow3AnimationDidStop() {
        word1.frame = wordButton1.frame
        word2.frame = wordButton2.frame
        word3.frame = wordButton3.frame
        word4.frame = wordButton4.frame

        view.bringSubviewToFront(word3)
        view.bringSubviewToFront(word4)

        tickView.isHidden = true
        crossView.isHidden = true
        tickView.transform = .identity
        crossView.transform = .identity

        if correct {
            wordModel.selectNextWord()
            let words = wordModel.getWords()

            word1.addWord(words[0])
            word2.addWord(words[1])
            word3.addWord(words[2])
            word4.addWord(words[3])

            wordButton1.setTitle(words[0], for: .normal)
            wordButton2.setTitle(words[1], for: .normal)
            wordButton3.setTitle(words[2], for: .normal)
            wordButton4.setTitle(words[3], for: .normal)

            definitionTV.text = wordModel.definition
        }

        score.text = gameStats.displayString
    }

    private func animateWord(toPlace selectedView: WordView) {
        // Bounces the placard back to the center
        guard let welcomeLayer = selectedView.layer as? CALayer else { return }

        // Create a keyframe animation to follow a path back to the center
        let bounceAnimation = CAKeyframeAnimation(keyPath: "position")
        bounceAnimation.isRemovedOnCompletion = false

        var animationDuration: CGFloat = 0.1

        // Create the path for the bounces
        let thePath = CGMutablePath()

        let midX = gapLabel.center.x
        let midY = gapLabel.center.y
        var originalOffsetX = selectedView.center.x - midX
        var originalOffsetY = selectedView.center.y - midY
        var offsetDivider: CGFloat = 4.0

        var stopBouncing = false

        // Start the path at the placard's current location
        thePath.move(to: CGPoint(x: selectedView.center.x, y: selectedView.center.y))
        thePath.addLine(to: CGPoint(x: midX, y: midY))

        // Add to the bounce path in decreasing excursions from the center
        while !stopBouncing {
            thePath.addLine(to: CGPoint(x: midX + originalOffsetX / offsetDivider, y: midY + originalOffsetY / offsetDivider))
            thePath.addLine(to: CGPoint(x: midX, y: midY))

            offsetDivider += 4
            animationDuration += 1 / offsetDivider
            if (abs(originalOffsetX / offsetDivider) < 6) && (abs(originalOffsetY / offsetDivider) < 6) {
                stopBouncing = true
            }
        }

        bounceAnimation.path = thePath
        bounceAnimation.duration = CFTimeInterval(animationDuration)

        // Create an animation group to combine the keyframe and basic animations
        let theGroup = CAAnimationGroup()

        // Set self as the delegate to allow for a callback to reenable user interaction
        theGroup.delegate = self
        theGroup.duration = CFTimeInterval(animationDuration)
        theGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        theGroup.animations = [bounceAnimation]

        // Add the animation group to the layer
        welcomeLayer.add(theGroup, forKey: "animatePlacardViewToCenter")

        // Set the placard view's center and transformation to the original values in preparation for the end of the animation
        selectedView.center = gapLabel.center
        selectedView.transform = .identity
        selected = selectedView.getWord()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    // MARK: - Helper Methods

    private func loadWordView() -> WordView? {
        guard let view = Bundle.main.loadNibNamed("WordView", owner: self, options: nil)?.first as? WordView else {
            return nil
        }
        view.isOpaque = true
        view.backgroundColor = .clear
        return view
    }
}

// MARK: - CAAnimationDelegate

extension BlanksViewController: CAAnimationDelegate {
    // This extension is needed to conform to CAAnimationDelegate protocol
    // The actual implementation is in the main class body at line 279
}
