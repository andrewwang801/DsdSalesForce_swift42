//
//  SurveyQuestion+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class SurveyQuestion: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        surveyID = ""
        questionType = ""
        questionText = ""
        questionID = ""
        multiResp = ""
        lookupNo = ""
        answer = ""
        selectedOptionIndex = -1
        isAnswered = false
    }

    func updateBy(theSource: SurveyQuestion) {

        self.surveyID = theSource.surveyID
        self.questionType = theSource.questionType
        self.questionText = theSource.questionText
        self.questionID = theSource.questionID
        self.multiResp = theSource.multiResp
        self.lookupNo = theSource.lookupNo
        self.answer = theSource.answer
        self.selectedOptionIndex = theSource.selectedOptionIndex
        self.isAnswered = theSource.isAnswered
    }

    func cloneBy(context: NSManagedObjectContext, theSource: SurveyQuestion) {
        updateBy(theSource: theSource)

        self.answerOptionSet.removeAllObjects()
        for _answer in theSource.answerOptionSet {
            let sourceAnswer = _answer as! SurveyAnswerOption
            let newAnswer = SurveyAnswerOption(context: context, forSave: managedObjectContext != nil)
            newAnswer.cloneBy(context: context, theSource: sourceAnswer)
            self.answerOptionSet.add(newAnswer)
            //newAnswer.question = self
        }
    }

    /*
    static func getBy(context: NSManagedObjectContext, surveyID: String) -> RouteSchedule? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RouteSchedule")
        request.predicate = NSPredicate(format: "custNo=%@", custNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails.first
        }
        return nil
    }*/

    static func getAll(context: NSManagedObjectContext) -> [SurveyQuestion] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SurveyQuestion")
        let result = try? context.fetch(request) as? [SurveyQuestion]

        if let result = result, let surveyQuestions = result {
            return surveyQuestions
        }
        return []
    }

    func fillAnswerOptions(context: NSManagedObjectContext, answerOptions: [SurveyAnswerOption]) {

        let lookupID = self.lookupNo ?? "0"
        let questionType = self.questionType ?? ""
        if questionType != "L" {
            return
        }
        for option in answerOptions {
            let answerOptionLookupID = option.lookupNo ?? "0"
            if answerOptionLookupID == lookupID {
                let newAnswerOption = SurveyAnswerOption(context: context, forSave: true)
                newAnswerOption.updateBy(theSource: option)
                newAnswerOption.question = self
            }
        }
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.surveyID = xmlDictionary["SurveyID"] ?? "0"
        self.questionID = xmlDictionary["QuestionID"] ?? "0"
        self.questionText = xmlDictionary["QuestionText"] ?? ""
        self.questionType = xmlDictionary["QuestionType"] ?? ""
        self.lookupNo = xmlDictionary["LookupNo"] ?? ""
        self.multiResp = xmlDictionary["MultiResp"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [SurveyQuestion] {

        deleteAll(context: context)

        // Survey Dist
        let dicArray = Utils.loadFromXML(xmlName: "SURVQUES", xPath: "//SurvQues/Records/SurvQues")
        var surveyQuestionArray = [SurveyQuestion]()
        for dic in dicArray {
            let surveyQuestion = SurveyQuestion(context: context, forSave: forSave)
            surveyQuestion.updateBy(xmlDictionary: dic)
            surveyQuestionArray.append(surveyQuestion)
        }
        return surveyQuestionArray
    }

    static func delete(context: NSManagedObjectContext, surveyQuestion: SurveyQuestion) {
        context.delete(surveyQuestion)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension SurveyQuestion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyQuestion> {
        return NSFetchRequest<SurveyQuestion>(entityName: "SurveyQuestion");
    }

    @NSManaged public var surveyID: String?
    @NSManaged public var questionType: String?
    @NSManaged public var questionText: String?
    @NSManaged public var questionID: String?
    @NSManaged public var multiResp: String?
    @NSManaged public var lookupNo: String?
    @NSManaged public var answer: String?

    @NSManaged public var selectedOptionIndex: Int32
    @NSManaged public var isAnswered: Bool

    @NSManaged public var survey: Survey?
    @NSManaged public var answerOptions: NSOrderedSet?
}

extension SurveyQuestion {

    var answerOptionSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "answerOptions")
    }
}

