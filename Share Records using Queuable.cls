public class PatentObjectQueuable implements Queueable {
    
    public Id patentId;
    public List<Id> patentIds;
    public Set<Id> managerIds=new Set<Id>();
    public Boolean processingDone =false;
    
    public PatentObjectQueuable(List<Id> patentIds){
        this.patentIds= patentIds;
    }
    
    public PatentObjectQueuable(Id patentId,Set<Id> managerIds){
        this.patentId = patentId;
        this.managerIds =managerIds;
    }
    
    public PatentObjectQueuable(){
        
    }
    
    public Set<Id> patenttoShareUsers1(Set<Id> setInventors){
        Set<Id> personManagerIds=new Set<Id>();
        for(SymphonyIPM__Inventor__c inventor:[SELECT First_Name__c,Id,Manager_Name__c,X2nd_level_Manager_Name__c,X3rd_level_Manager_Name__c,
                                                X4th_level_Manager_Name__c,X5th_level_Manager_Name__c,
                                                X6th_level_Manager_Name__c,X7th_level_Manager_Name__c,X8th_level_Manager_Name__c,
                                                X9th_level_Manager_Name__c,X10th_level_Manager_Name__c,X11th_level_Manager_Name__c,
                                                X12th_level_Manager_Name__c,X13th_level_Manager_Name__c 
                                               FROM SymphonyIPM__Inventor__c WHERE Id IN : setInventors])
        {
            if(inventor.Manager_Name__c != null){
               personManagerIds.add(inventor.Manager_Name__c);
            }

            if(inventor.X2nd_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X2nd_level_Manager_Name__c);
            }

            if(inventor.X3rd_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X3rd_level_Manager_Name__c);
            }

            if(inventor.X4th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X4th_level_Manager_Name__c);
            }

            if(inventor.X5th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X5th_level_Manager_Name__c);
            }

            if(inventor.X6th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X6th_level_Manager_Name__c);
            }

            if(inventor.X7th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X7th_level_Manager_Name__c);
            }

            if(inventor.X8th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X8th_level_Manager_Name__c);
            }

            if(inventor.X9th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X9th_level_Manager_Name__c );
            }

            if(inventor.X10th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X10th_level_Manager_Name__c );
            }

            if(inventor.X11th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X11th_level_Manager_Name__c );
            }

            if(inventor.X12th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X12th_level_Manager_Name__c );
            }
            
            if(inventor.X13th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X13th_level_Manager_Name__c );
            }
        }
        System.debug(personManagerIds);
        return personManagerIds;
    }
    
    public Set<Id> patenttoShareUsers(Set<Id> setInventors){
        Set<Id> personManagerIds=new Set<Id>();
        for(SymphonyIPM__Inventor__c inventor:[SELECT First_Name__c,Id,Manager_Name__c,X2nd_level_Manager_Name__c,X3rd_level_Manager_Name__c,
                                                X4th_level_Manager_Name__c,X5th_level_Manager_Name__c,
                                                X6th_level_Manager_Name__c,X7th_level_Manager_Name__c,X8th_level_Manager_Name__c,
                                                X9th_level_Manager_Name__c,X10th_level_Manager_Name__c,X11th_level_Manager_Name__c,
                                                X12th_level_Manager_Name__c,X13th_level_Manager_Name__c 
                                               FROM SymphonyIPM__Inventor__c WHERE Id IN : setInventors])
        {
            if(inventor.Manager_Name__c != null){
               personManagerIds.add(inventor.Manager_Name__c);
            }

            if(inventor.X2nd_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X2nd_level_Manager_Name__c);
            }

            if(inventor.X3rd_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X3rd_level_Manager_Name__c);
            }

            if(inventor.X4th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X4th_level_Manager_Name__c);
            }

            if(inventor.X5th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X5th_level_Manager_Name__c);
            }

            if(inventor.X6th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X6th_level_Manager_Name__c);
            }

            if(inventor.X7th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X7th_level_Manager_Name__c);
            }

            if(inventor.X8th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X8th_level_Manager_Name__c);
            }

            if(inventor.X9th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X9th_level_Manager_Name__c );
            }

            if(inventor.X10th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X10th_level_Manager_Name__c );
            }

            if(inventor.X11th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X11th_level_Manager_Name__c );
            }

            if(inventor.X12th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X12th_level_Manager_Name__c );
            }
            
            if(inventor.X13th_level_Manager_Name__c != null){
               personManagerIds.add(inventor.X13th_level_Manager_Name__c );
            }
        }
        
        System.debug(personManagerIds);
        if(!personManagerIds.isEmpty()){
            Set<Id> managers=new Set<Id>();
            do {
                PatentObjectQueuable pq=new PatentObjectQueuable();
                managers=pq.patenttoShareUsers1(personManagerIds);
                Boolean hasNewData=false;
                for(Id currentId:managers){
                    if(!personManagerIds.contains(currentId)){
                        hasNewData =true;
                    }
                }
                
                if(!hasNewData){
                    managers.clear();
                }
                personManagerIds.addAll(managers);
                
                
            } while (!managers.isEmpty());
        }
        return personManagerIds;
    }
    
    public void execute(QueueableContext context) {            
        
        Set<Id> setPatentUsers=new Set<Id>();
        patentId =patentIds[0];
        for(SymphonyIPM__Patent__c patent:[Select Temporary_Firm__c,SymphonyIPM__Annuity_Payer__c,SymphonyIPM__Business_Contact__c,SymphonyIPM__Docketing_Contact__c,
                                           Symphony_IPM_Family_Attorney__c,SymphonyIPM__First_Named_Inventor__c,SymphonyIPM__Foreign_Agent__c,SymphonyIPM__Inventor__c,Paralegal__c,
                                           SymphonyIPM__Portfolio_Manager__c,SymphonyIPM__Primary_Inventor__c,Prosecuting_Counsel__c from SymphonyIPM__Patent__c Where Id = : patentId])
        {
            if(patent.Temporary_Firm__c != null){
                setPatentUsers.add(patent.Temporary_Firm__c);        
            }
            
            if(patent.SymphonyIPM__Annuity_Payer__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Annuity_Payer__c);        
            }
            
            if(patent.SymphonyIPM__Business_Contact__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Business_Contact__c);        
            }
            
            if(patent.SymphonyIPM__Docketing_Contact__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Docketing_Contact__c);        
            }
            
            if(patent.Symphony_IPM_Family_Attorney__c != null){
                setPatentUsers.add(patent.Symphony_IPM_Family_Attorney__c);        
            }
       
            if(patent.SymphonyIPM__First_Named_Inventor__c != null){
                setPatentUsers.add(patent.SymphonyIPM__First_Named_Inventor__c);        
            }
            
            if(patent.SymphonyIPM__Foreign_Agent__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Foreign_Agent__c);        
            }
            
            if(patent.SymphonyIPM__Inventor__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Inventor__c);        
            }
            
            if(patent.Paralegal__c != null){
                setPatentUsers.add(patent.Paralegal__c);        
            }
            
            if(patent.SymphonyIPM__Portfolio_Manager__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Portfolio_Manager__c);        
            }
            
            if(patent.SymphonyIPM__Primary_Inventor__c != null){
                setPatentUsers.add(patent.SymphonyIPM__Primary_Inventor__c);        
            }
            
            if(patent.Prosecuting_Counsel__c != null){
                setPatentUsers.add(patent.Prosecuting_Counsel__c);        
            }
            
        }
        
        System.debug(setPatentUsers);
        if(!setPatentUsers.isEmpty()){
            PatentObjectQueuable pInstance=new PatentObjectQueuable();
            Set<Id> personManagerIds=pInstance.patenttoShareUsers(setPatentUsers);
            personManagerIds.addAll(setPatentUsers);
            
            if(!personManagerIds.isEmpty()){
                for(SymphonyIPM__Inventor__c inventor:[SELECT SymphonyIPM__User__c FROM SymphonyIPM__Inventor__c WHERE Id IN : personManagerIds AND SymphonyIPM__User__c != null])
                {
                    managerIds.add(inventor.SymphonyIPM__User__c);
                }
                
                if(!managerIds.isEmpty()){
                    Map<Id,Id> mapPatentshareUsers=new Map<Id,Id>();
                    for(SymphonyIPM__Patent__Share pShare:[SELECT UserOrGroupId FROM SymphonyIPM__Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual'])
                    {
                        mapPatentshareUsers.put(pShare.UserOrGroupId,pShare.UserOrGroupId);
                    }
                    
                    for(Id userId:mapPatentshareUsers.keySet()){
                        if(managerIds.contains(userId)){
                            mapPatentshareUsers.remove(userId);
                            managerIds.remove(userId);
                        }
                    }
                    
                    if(!mapPatentshareUsers.isEmpty()){
                        Delete [Select Id from SymphonyIPM__Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual' AND UserOrGroupId IN : mapPatentshareUsers.keySet()];
                    }
                    
                    if(!managerIds.isEmpty()){
                        List<SymphonyIPM__Patent__Share> lstPatentShare =new List<SymphonyIPM__Patent__Share>();
                        for(Id userId: managerIds){
                            SymphonyIPM__Patent__Share pShare =new SymphonyIPM__Patent__Share(ParentId = patentId, UserOrGroupId = userId,
                            AccessLevel = 'Read',RowCause = Schema.SymphonyIPM__Patent__Share.RowCause.Manual);
                            lstPatentShare.add(pShare);
                        }
                        
                        System.debug(lstPatentShare);
                        If(!lstPatentShare.isEmpty()){
                            database.insert(lstPatentShare,false);
                        }
                    }
                }
                
            }else{
                Delete [Select Id from SymphonyIPM__Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual'];
            }
            
            patentIds.remove(0);
            if(patentIds.size() >0){
                System.enqueueJob(new PatentObjectQueuable(patentIds)); 
            }
        }
    }
}