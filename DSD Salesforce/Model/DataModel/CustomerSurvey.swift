//
//  CustomerSurvey.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class CustomerSurvery {

    var question = ""
    var answers = [String]()
    var isAnswered = false
    var answeredIndex = -1

    init(question: String, answers: [String]) {
        self.question = question
        self.answers = answers
    }

    convenience init(question: String) {
        self.init(question: question, answers: [String]())
    }

    func addAnswers(answers: [String]) {
        self.answers.append(contentsOf: answers)
    }

    func answer(index: Int) {
        if index < 0 || index >= answers.count {
            return
        }
        isAnswered = true
        answeredIndex = index
    }

}
