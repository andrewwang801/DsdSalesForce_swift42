//
//  Survey+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class Survey: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        surveyType = ""
        surveyTitle = ""
        surveyID = ""
        mandatory = false
        custNo = ""
        chainNo = ""
        createDate = ""
        completionDate = ""
    }

    var isCompleted: Bool {
        get {
            for _question in questionSet {
                let question = _question as! SurveyQuestion
                if question.isAnswered == false {
                    return false
                }
            }
            return true
        }
    }

    var completedPercent: Double {
        get {
            let questionCount = questionSet.count
            var answeredCount = 0
            for _question in questionSet {
                let question = _question as! SurveyQuestion
                if question.isAnswered == true {
                    answeredCount += 1
                }
            }
            if questionCount == 0 {
                return 0
            }
            else {
                return Double(answeredCount)/Double(questionCount)*100
            }
        }
    }

    func updateBy(theSource: Survey) {

        self.surveyType = theSource.surveyType
        self.surveyTitle = theSource.surveyTitle
        self.surveyID = theSource.surveyID
        self.mandatory = theSource.mandatory
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.createDate = theSource.createDate
        self.completionDate = theSource.completionDate
    }

    func cloneBy(context: NSManagedObjectContext, theSource: Survey) {
        updateBy(theSource: theSource)

        self.questionSet.removeAllObjects()
        for _question in theSource.questionSet {
            let sourceQuestion = _question as! SurveyQuestion
            let newQuestion = SurveyQuestion(context: context, forSave: managedObjectContext != nil)
            newQuestion.cloneBy(context: context, theSource: sourceQuestion)
            self.questionSet.add(newQuestion)
            //newQuestion.survey = self
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

    static func getAll(context: NSManagedObjectContext) -> [Survey] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Survey")
        let result = try? context.fetch(request) as? [Survey]

        if let result = result, let surveys = result {
            return surveys
        }
        return []
    }

    func fillQuestions(context: NSManagedObjectContext, questionArray: [SurveyQuestion]) {

        let surveyID = self.surveyID ?? "0"
        for question in questionArray {
            let questionSurveyID = question.surveyID ?? "0"
            if questionSurveyID == surveyID {
                let newSurveyQuestion = SurveyQuestion(context: context, forSave: true)
                newSurveyQuestion.updateBy(theSource: question)
                newSurveyQuestion.survey = self
            }
        }
    }

    func updateByDist(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.surveyID = xmlDictionary["SurveyID"] ?? "0"
    }

    func updateByHead(xmlDictionary: [String: String]) {
        self.surveyTitle = xmlDictionary["SurveyTtl"] ?? ""
        self.createDate = xmlDictionary["CreateDate"] ?? ""
        self.completionDate = xmlDictionary["CompletionDate"] ?? ""
        self.mandatory = (xmlDictionary["Mandatory"] ?? "") == "Y"
        self.surveyType = xmlDictionary["SurveyType"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [Survey] {

        deleteAll(context: context)

        // Survey Dist
        let dicArray = Utils.loadFromXML(xmlName: "SURVDIST", xPath: "//SurvDist/Records/SurvDist")
        var surveyArray = [Survey]()
        for dic in dicArray {
            let survey = Survey(context: context, forSave: forSave)
            survey.updateByDist(xmlDictionary: dic)
            surveyArray.append(survey)
        }

        // update from Survey Head
        let headDicArray = Utils.loadFromXML(xmlName: "SURVHEAD", xPath: "//SurvHead/Records/SurvHead")
        for dic in headDicArray {
            let dicSurveyID = dic["SurveyID"] ?? ""
            for survey in surveyArray {
                if survey.surveyID == dicSurveyID {
                    survey.updateByHead(xmlDictionary: dic)
                    break
                }
            }
        }
        return surveyArray
    }

    static func delete(context: NSManagedObjectContext, survey: Survey) {
        context.delete(survey)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension Survey {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Survey> {
        return NSFetchRequest<Survey>(entityName: "Survey");
    }

    @NSManaged public var surveyType: String?
    @NSManaged public var surveyTitle: String?
    @NSManaged public var surveyID: String?
    @NSManaged public var mandatory: Bool
    @NSManaged public var custNo: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var createDate: String?
    @NSManaged public var completionDate: String?

    @NSManaged public var customerDetail: CustomerDetail?
    @NSManaged public var questions: NSOrderedSet?
}

extension Survey {

    var questionSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "questions")
    }
}

