//
//  SurveyAnswerOption+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class SurveyAnswerOption: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        lookupNo = ""
        optionValue = ""
    }

    func updateBy(theSource: SurveyAnswerOption) {

        self.lookupNo = theSource.lookupNo
        self.optionValue = theSource.optionValue
    }

    func cloneBy(context: NSManagedObjectContext, theSource: SurveyAnswerOption) {
        updateBy(theSource: theSource)
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

    static func getAll(context: NSManagedObjectContext) -> [SurveyAnswerOption] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SurveyAnswerOption")
        let result = try? context.fetch(request) as? [SurveyAnswerOption]

        if let result = result, let surveyAnswerOptions = result {
            return surveyAnswerOptions
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.lookupNo = xmlDictionary["LookupNo"] ?? ""
        self.optionValue = xmlDictionary["QuestionVal"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [SurveyAnswerOption] {

        deleteAll(context: context)

        // Survey Dist
        let dicArray = Utils.loadFromXML(xmlName: "SURVQOPT", xPath: "//SurvQOpt/Records/SurvQopt")
        var optionArray = [SurveyAnswerOption]()
        for dic in dicArray {
            let answerOption = SurveyAnswerOption(context: context, forSave: forSave)
            answerOption.updateBy(xmlDictionary: dic)
            optionArray.append(answerOption)
        }
        return optionArray
    }

    static func delete(context: NSManagedObjectContext, answerOption: SurveyAnswerOption) {
        context.delete(answerOption)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension SurveyAnswerOption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyAnswerOption> {
        return NSFetchRequest<SurveyAnswerOption>(entityName: "SurveyAnswerOption");
    }

    @NSManaged public var lookupNo: String?
    @NSManaged public var optionValue: String?

    @NSManaged public var question: SurveyQuestion?
}

