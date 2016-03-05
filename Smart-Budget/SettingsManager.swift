//
//  SettingsManager.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 3/5/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData

public class SettingsManager
{
    static var MySettings: Settings?
    
    public static func CreateSettings()
    {
        let entityDescription = NSEntityDescription.entityForName("Settings", inManagedObjectContext: SummaryManager.GetContext())
        
        MySettings = Settings(entity: entityDescription!, insertIntoManagedObjectContext: SummaryManager.GetContext())
        
        do
        {
            try SummaryManager.GetContext().save()
        }
        catch
        {
            
        }
    }
    
    public static func CreateSettings(newSettings: Settings)
    {
        MySettings = newSettings
    }
}