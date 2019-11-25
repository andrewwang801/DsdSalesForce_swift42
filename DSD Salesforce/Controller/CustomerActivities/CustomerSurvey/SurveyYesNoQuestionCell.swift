//
//  SurveyYesNoQuestionCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SurveyYesNoQuestionCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var questionNoLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerCollectionView: UICollectionView!
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

        // answer collection view
        answerCollectionView.dataSource = self
        answerCollectionView.delegate = self
        answerCollectionView.backgroundView?.backgroundColor = UIColor.clear
        answerCollectionView.backgroundColor = UIColor.clear

        if index == parentVC.survey.questionSet.count-1 {
            mainViewBottomMarginConstraint.constant = 0
        }
        else {
            mainViewBottomMarginConstraint.constant = kSurveyVerticalMargin
        }

        reloadAnswers()
    }

    func reloadAnswers() {
        answerCollectionView.reloadData()
    }

}

extension SurveyYesNoQuestionCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QuestionYesNoAnswerCell.kAnswerValueArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionYesNoAnswerCell", for: indexPath) as! QuestionYesNoAnswerCell
        cell.setupCell(questionCell: self, indexPath: indexPath)
        return cell
    }
}

extension SurveyYesNoQuestionCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kCols = kSurveyAnswersPerRow
        let totalWidth = collectionView.bounds.width
        let width = floor(totalWidth/CGFloat(kCols))
        let height = kSurveyAnswerCellHeight
        let lastWidth = totalWidth-width
        let index = indexPath.row
        let col = index % kCols

        if col < kCols-1 {
            return CGSize(width: width, height: height)
        }
        else {
            return CGSize(width: lastWidth, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

