//
//  ViewController.swift
//  JaywayQuiz
//
//  Created by Bjørn Lau Jørgensen on 19/11/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var questionsInCurrentGame = [Question]()
    var currentPresentedQuestion: Question!
    var currentCorrectAnswer: String?
    var currentGameTime: Double!
    
    var breakTimer = Timer()
    var questionTimer = Timer()

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var answerLabel: [SpringButton]!
    @IBOutlet weak var timeLabel: SpringLabel!
    @IBOutlet weak var fiftyFiftyLabel: SpringButton!
    @IBOutlet weak var extraSecondsLabel: SpringButton!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var imageQuestionLabel: UILabel!
    @IBOutlet weak var resultOverlay: UIView!
    
    
    //  CONFIGURE & PLAY - Happy times! <:)
    func configureAndPlay() {
        config = Configuration.init()
        questionsInCurrentGame = Question.prepareQuestionsForGame(questionObjects: questionArray)
        Result.resetResult()
        presentQuestion()
        resultOverlay.isHidden = true
    }
    
    //  Capture result before segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Result.captureResult()
    }
    
    //  Disabels half of the answers - but only 2 that is wrong.
    //  50/50 only works with an even number of answers.
    func fiftyFifty() {
        if answerLabel.count % 2 == 0 {
            
            var numberOfAnswers = Array(0..<answerLabel.count)
            
            if let indexOfCorrectAnswer = answerLabel.firstIndex(where: { $0.title(for: .normal) == currentCorrectAnswer }) {
                numberOfAnswers.remove(at: indexOfCorrectAnswer)
                let randomized = numberOfAnswers.shuffled()
                let wrongAnswers = randomized.prefix(answerLabel.count / 2)
                
                for i in wrongAnswers {
                    answerLabel[i].alpha = 0.5
                    answerLabel[i].isUserInteractionEnabled = false
                }
            }
        }
    }
    
    
    //  Start question timer.
    func startTimer() {
        questionTimer.invalidate()
        timeLabel.text = "\(config.numberOfMillisecondsForQuestion)"
        currentGameTime = config.numberOfMillisecondsForQuestion - 1.0
        
        timeLabel.animation = "squeezeDown"
        timeLabel.curve = "easeIn"
        timeLabel.duration = 1.0
        timeLabel.animate()
        
        questionTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    
    //  Update game time label.
    @objc func updateTime() {
        let msToS = currentGameTime / 1000
        let oneDigitFormat = String(format: "%.1f", msToS)
        timeLabel.text = "\(oneDigitFormat)"

        if currentGameTime != 0.0 {
            currentGameTime! -= 1.0
        } else {
            questionTimer.invalidate()
            questionLabel.textColor = Color().unanswerdYellow
            imageQuestionLabel.textColor = Color().unanswerdYellow
            resutlUnanswered += 1
            presentNextQuestion()
        }
        
        if currentGameTime == config.numberOfMillisecondsForQuestion - config.numberOfPlusMiliseconds && config.numberOfExtraSeconds != 0  {
            extraSecondsLabel.setBackgroundImage(UIImage(named: "plus10_active"), for: .normal)
            extraSecondsLabel.isUserInteractionEnabled = true
            extraSecondsLabel.alpha = 1.0
            
            extraSecondsLabel.animation = "pop"
            extraSecondsLabel.curve = "easeInOut"
            extraSecondsLabel.duration = 1.0
            extraSecondsLabel.animate()
        }
        
        if currentGameTime == config.numberOfMsLeftToActivateFiftyFifty && config.numberOfFiftyFifty != 0 {
            fiftyFiftyLabel.animate()
            fiftyFiftyLabel.setBackgroundImage(UIImage(named: "fiftyfifty_active"), for: .normal)
            fiftyFiftyLabel.isUserInteractionEnabled = true
            fiftyFiftyLabel.alpha = 1.0
            
            fiftyFiftyLabel.animation = "pop"
            fiftyFiftyLabel.curve = "easeInOut"
            fiftyFiftyLabel.duration = 1.0
            fiftyFiftyLabel.animate()
        }
    }
    
    //  Resets the controls when a new question is presented.
    func resetControls() {
        startTimer()
        activeButtons(true)
        questionImageView.image = nil
        questionLabel.textColor = UIColor.white
        imageQuestionLabel.textColor = UIColor.white
        
        for i in 0..<self.answerLabel.count {
            self.answerLabel[i].backgroundColor = UIColor.white
            self.answerLabel[i].alpha = 1.0
            self.answerLabel[i].setTitleColor(Color().swiftyGreen, for: .normal)
        }
        
        fiftyFiftyLabel.isUserInteractionEnabled = false
        if config.numberOfFiftyFifty != 0 {
            fiftyFiftyLabel.setBackgroundImage(UIImage(named: "fiftyfifty_inactive"), for: .normal)
            fiftyFiftyLabel.alpha = 0.3
        }
        
        extraSecondsLabel.isUserInteractionEnabled = false
        if config.numberOfExtraSeconds != 0 {
            extraSecondsLabel.setBackgroundImage(UIImage(named: "plus10_inactive"), for: .normal)
            extraSecondsLabel.alpha = 0.3
        }
    }
    
    //  Presents a new question and marks the question as .used in original data.
    func presentQuestion() {
        currentPresentedQuestion = questionsInCurrentGame[0]
        currentCorrectAnswer = currentPresentedQuestion.correctAnswer
        Question.markQuestionsAsUsed(question: currentPresentedQuestion)
        resetControls()
        
        //  Sets the labels to the current answers.
        for i in 0..<answerLabel.count {
            answerLabel[i].setTitle(currentPresentedQuestion.answers[i], for: .normal)
        }
        
        //  Fetches images from server.
        if currentPresentedQuestion.questionImage.isEmpty {
            questionLabel.text = currentPresentedQuestion.questionString
            imageQuestionLabel.text = nil
        } else {
            questionLabel.text = nil
            imageQuestionLabel.text = currentPresentedQuestion.questionString
            
            DataFetch.fetchImage(urlPath: "\(currentPresentedQuestion.questionImage)", CompletionHandler: {image in
              if let currentImage = image {
                DispatchQueue.main.async {
                    self.questionImageView.image = currentImage
                }
              }
            })
        }
        
    }
    
    //  Remove the answer from the current game list.
    func removeAskedQuestion() {
        if questionsInCurrentGame.count >= 1 {
            questionsInCurrentGame.remove(at: 0)
        }
    }
    
    //  Enables or disables buttons. (Active: true, Disabled: false)
    func activeButtons(_ trueOrFalse: Bool) {
        for i in 0..<answerLabel.count {
            answerLabel[i].isUserInteractionEnabled = trueOrFalse
        }
    }
    
    //  Animates view from hidden.
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //  Fires the next question.
    func presentNextQuestion() {
        activeButtons(false)
        
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
            self.removeAskedQuestion()
            resultTime.append(self.currentGameTime)
            
            if self.questionsInCurrentGame.count != 0 {
                self.presentQuestion()
            } else if self.questionsInCurrentGame.count == 0 {
                self.setView(view: self.resultOverlay, hidden: false)
            }
        }
    }
    
    //  Checks if the answer selected is correct.
    func checkAnswer(answer: String) -> Bool {
        if answer == currentCorrectAnswer {
            return true
        } else {
            if let index = currentPresentedQuestion.answers.firstIndex(where: { currentCorrectAnswer! == $0 }) {
                answerLabel[index].backgroundColor = Color().correctGreen
                answerLabel[index].animation = "flash"
                answerLabel[index].curve = "easeIn"
                answerLabel[index].duration = 0.2
                answerLabel[index].animate()
            }
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAndPlay()
    }
    
    @IBAction func seeResultButton(_ sender: Any) {
        self.performSegue(withIdentifier: "presentResult", sender: self)
    }
    
    
    //  ----------- ACTIONS -----------
    
    @IBAction func extraSecondsButton(_ sender: UIButton) {
        extraSecondsLabel.isUserInteractionEnabled = false
        extraSecondsLabel.alpha = 0.2
        resultLifelinesUsed += 1
        config.numberOfExtraSeconds -= 1
        currentGameTime += config.numberOfPlusMiliseconds
    }
    
    @IBAction func fiftyFiftyButton(_ sender: UIButton) {
        fiftyFiftyLabel.isUserInteractionEnabled = false
        fiftyFiftyLabel.alpha = 0.2
        resultLifelinesUsed += 1
        config.numberOfFiftyFifty -= 1
        fiftyFifty()
    }
    
    @IBAction func answerButton(_ sender: UIButton) {
        questionTimer.invalidate()
        presentNextQuestion()
        
        if let buttonTitle = sender.title(for: .normal) {
            if checkAnswer(answer: buttonTitle) {
                sender.setTitleColor(UIColor.black, for: .normal)
                sender.backgroundColor = Color().correctGreen
                resultCorrectAnswer += 1
            } else {
                sender.setTitleColor(UIColor.black, for: .normal)
                sender.backgroundColor = Color().wrongRed
                resultWrongAnswer += 1
            }
        }
    }
    
}
