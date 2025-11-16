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

    var word1: WordView!
    var word2: WordView!
    var word3: WordView!
    var word4: WordView!

    // XXX TODO better in word model??
    var correctCount: Float = 0.0
    var wrongCount: Float = 0.0
    var streak: Float = 0.0
    var highestStreak: NSNumber = 0

    var selected: String = ""
    var correct = false

    // MARK: - Constants

    let GROW_ANIMATION_DURATION_SECONDS = 0.15
    let SHRINK_ANIMATION_DURATION_SECONDS = 0.15

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        wordModel = WordModel()
        streak = 0.0

        if let savedHighScore = UserDefaults.standard.object(forKey: "HighScore") as? NSNumber {
            highestStreak = savedHighScore
        } else {
            highestStreak = NSNumber(value: 0.0)
            UserDefaults.standard.set(highestStreak, forKey: "HighScore")
        }

        let words = wordModel.getWords()

        // Load word views from XIB
        word1 = Bundle.main.loadNibNamed("WordView", owner: self, options: nil)?.first as? WordView
        word1.isOpaque = true
        word1.backgroundColor = .clear

        word2 = Bundle.main.loadNibNamed("WordView", owner: self, options: nil)?.first as? WordView
        word2.isOpaque = true
        word2.backgroundColor = .clear

        word3 = Bundle.main.loadNibNamed("WordView", owner: self, options: nil)?.first as? WordView
        word3.isOpaque = true
        word3.backgroundColor = .clear

        word4 = Bundle.main.loadNibNamed("WordView", owner: self, options: nil)?.first as? WordView
        word4.isOpaque = true
        word4.backgroundColor = .clear

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

        score.text = String(format: "streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%", 0.0, 0.0, 0.0 * 100)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let defaults = UserDefaults.standard
        if defaults.object(forKey: "TappingUI") != nil {
            isTapping = defaults.bool(forKey: "TappingUI")
        } else {
            defaults.set(false, forKey: "TappingUI")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Check Answer

    @IBAction func answerPressed(_ sender: Any) {
        if isTapping {
            guard let button = sender as? UIButton,
                  let titleText = button.titleLabel?.text else { return }

            selected = titleText
            var result: UIImageView

            if selected == wordModel.correct {
                correct = true
                result = tickView
                // put this in WordModel or Statsmodel
                correctCount += 1
                streak += 1

                if streak > highestStreak.floatValue {
                    highestStreak = NSNumber(value: streak)
                    UserDefaults.standard.set(highestStreak, forKey: "HighScore")
                }
            } else {
                correct = false
                result = crossView
                wrongCount += 1
                streak = 0.0
            }

            result.isHidden = false
            animateCorrectWrongView(result)
        }
    }

    func animateCorrectWrongView(_ selectedView: UIImageView) {
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
        if segue.identifier == "showAlternate" {
            if let destination = segue.destination as? OptionsViewController {
                destination.delegate = self
            }
        }
    }

    // MARK: - Handling Touch

    // adds a set of gesture recognizers to one of our piece subviews
    func addGestureRecognizers(to piece: UIView) {
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
    func adjustAnchorPoint(for gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            guard let piece = gestureRecognizer.view else { return }
            let locationInSuperview = gestureRecognizer.location(in: piece.superview)
            piece.center = locationInSuperview
        }
    }

    func animateFirstTouch(at touchPoint: CGPoint, on selectedView: WordView) {
        UIView.animate(withDuration: GROW_ANIMATION_DURATION_SECONDS, animations: {
            let transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            selectedView.transform = transform
        }, completion: { _ in
            self.growAnimationDidStop()
        })

        UIView.animate(withDuration: GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS) {
            selectedView.center = touchPoint
        }
    }

    func growAnimationDidStop() {
        UIView.animate(withDuration: SHRINK_ANIMATION_DURATION_SECONDS) {
            // Animation completion
        }
    }

    func animationDidStop(_ theAnimation: CAAnimation, finished flag: Bool) {
        var result: UIImageView

        if selected == wordModel.correct {
            correct = true
            result = tickView
            // put this in WordModel or Statsmodel
            correctCount += 1
            streak += 1

            if streak > highestStreak.floatValue {
                highestStreak = NSNumber(value: streak)
                UserDefaults.standard.set(highestStreak, forKey: "HighScore")
            }
        } else {
            correct = false
            result = crossView
            wrongCount += 1
            streak = 0.0
        }

        result.isHidden = false
        animateCorrectWrongView(result)
    }

    func grow3AnimationDidStop() {
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

        var percentage = correctCount / (correctCount + wrongCount)
        if correctCount == 0 {
            percentage = 0.0
        }

        // XXX TODO String extern def
        let showing = String(format: "streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%", streak, correctCount, percentage * 100)
        score.text = showing
    }

    func animateWord(toPlace selectedView: WordView) {
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
}

// MARK: - CAAnimationDelegate

extension BlanksViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationDidStop(anim, finished: flag)
    }
}
