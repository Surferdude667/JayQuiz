//
//  Result.swift
//  JaywayQuiz
//
//  Created by Bjørn Lau Jørgensen on 21/11/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

var resultPack: Result?
var resultTime = [Double]()
var resultCorrectAnswer: Int!
var resultWrongAnswer: Int!
var resutlUnanswered: Int!
var resultLifelinesUsed: Int!

class Result {
    
    var correctAnswers: Int
    var wrongAnswers: Int
    var unansweredAnswers: Int
    var answerTime = [Double]()
    var lifelinesUsed: Int
    
    init(correctAnswers: Int, wrongAnswers: Int, unansweredAnswers: Int, answerTime: [Double], lifelinesUsed: Int) {
        self.correctAnswers = correctAnswers
        self.wrongAnswers = wrongAnswers
        self.unansweredAnswers = unansweredAnswers
        self.answerTime = answerTime
        self.lifelinesUsed = lifelinesUsed
    }
    
    static func captureResult() {
        resultPack = Result(correctAnswers: resultCorrectAnswer,
                                 wrongAnswers: resultWrongAnswer,
                                 unansweredAnswers: resutlUnanswered,
                                 answerTime: resultTime,
                                 lifelinesUsed: resultLifelinesUsed)
    }
    
    static func resetResult() {
        resultTime.removeAll()
        resultCorrectAnswer = 0
        resultWrongAnswer = 0
        resutlUnanswered = 0
        resultLifelinesUsed = 0
        resultPack = nil
    }
    
}
