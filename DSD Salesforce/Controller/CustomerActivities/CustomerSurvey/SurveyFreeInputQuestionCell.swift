//
//  SurveyFreeInputQuestionCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class SurveyFreeInputQuestionCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var questionNoLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var answerText: AnimatableTextField!
    @IBOutlet weak var mainViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerRightMarginConstraint: NSLayoutConstraint!

    var parentVC: CustomerSurveyVC!
    var indexPath: IndexPath!
    var question: SurveyQuestion!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerTopMarginConstraint.constant = kSurveyInnerTopMargin
        innerBottomMarginConstraint.constant = kSurveyInnerBottomMargin

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: CustomerSurveyVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        self.question = parentVC.survey.questionSet[indexPath.row] as! SurveyQuestion
        configCell()
    }

    func configCell() {

        selectionStyle = .none
        let index = indexPath.row
        let survey = parentVC.survey!
        let question = survey.questionSet[index] as! SurveyQuestion

        // question
        questionNoLabel.text = "\(index+1)"
        questionLabel.text = (question.questionText ?? "").uppercased()

        if index == parentVC.survey.questionSet.count-1 {
            mainViewBottomMarginConstraint.constant = 0
        }
        else {
            mainViewBottomMarginConstraint.constant = kSurveyVerticalMargin
        }

        answerText.delegate = self
        answerText.addTarget(self, action: #selector(SurveyFreeInputQuestionCell.onChangedAnswerText), for: .editingChanged)
        answerText.returnKeyType = .done
        answerText.text = question.answer ?? ""
    }

    @objc func onChangedAnswerText(_ sender: Any) {
        let answer = answerText.text ?? ""
        question.answer = answer
        question.isAnswered = (answer.isEmpty == false)
        parentVC.updatePercent()
    }

}

extension SurveyFreeInputQuestionCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == answerText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

}


