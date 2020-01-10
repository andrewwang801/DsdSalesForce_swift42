//
//  QuestionYesNoAnswerCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class QuestionYesNoAnswerCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var answerNameLabel: UILabel!
    @IBOutlet weak var radioLabel: AnimatableLabel!

    var questionCell: SurveyYesNoQuestionCell!
    var indexPath: IndexPath!
    static let kAnswerValueArray = [L10n.yes(), L10n.no()]

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuestionYesNoAnswerCell.onTapMain(_:)))
        mainView.addGestureRecognizer(tapGesture)
    }

    func setupCell(questionCell: SurveyYesNoQuestionCell, indexPath: IndexPath) {
        self.questionCell = questionCell
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        let question = questionCell.question
        let answerIndex = indexPath.row
        self.backgroundColor = UIColor.clear
        self.answerNameLabel.text = QuestionYesNoAnswerCell.kAnswerValueArray[answerIndex]
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
        let answerValue = QuestionYesNoAnswerCell.kAnswerValueArray[answerIndex]
        question!.selectedOptionIndex = answerIndex.int32
        question!.answer = answerValue
        question!.isAnswered = true

        questionCell.answerCollectionView.reloadData()
        questionCell.parentVC.updatePercent()
    }
}
