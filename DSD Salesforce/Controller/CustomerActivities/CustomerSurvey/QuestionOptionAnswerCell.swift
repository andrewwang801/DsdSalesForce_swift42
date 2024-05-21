//
//  QuestionAnswerItemCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class QuestionOptionAnswerCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var answerNameLabel: UILabel!
    @IBOutlet weak var radioLabel: AnimatableLabel!

    var questionCell: SurveyOptionQuestionCell!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuestionOptionAnswerCell.onTapMain(_:)))
        mainView.addGestureRecognizer(tapGesture)
    }

    func setupCell(questionCell: SurveyOptionQuestionCell, indexPath: IndexPath) {
        self.questionCell = questionCell
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        let answerIndex = indexPath.row
        let question = questionCell.question
        let answer = question!.answerOptionSet[answerIndex] as! SurveyAnswerOption

        self.backgroundColor = UIColor.clear
        self.answerNameLabel.text = answer.optionValue ?? ""

        let selectedOptionIndex = question!.selectedOptionIndex
        if answerIndex == selectedOptionIndex {
            self.radioLabel.backgroundColor = kReasonOptionSelectedColor
        }
        else {
            self.radioLabel.backgroundColor = kReasonOptionNormalColor
        }
    }

    @objc func onTapMain(_ sender: Any) {
        let answerIndex = indexPath.row
        let question = questionCell.question
        let answerOption = question!.answerOptionSet[answerIndex] as! SurveyAnswerOption
        question!.selectedOptionIndex = answerIndex.int32
        question!.answer = answerOption.optionValue ?? ""
        question!.isAnswered = true

        questionCell.answerCollectionView.reloadData()
        questionCell.parentVC.updatePercent()
    }
}
