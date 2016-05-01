public class ComboBox_Con {
    
    private Object targetField;
    public String labelField{ get; set; }
    public String valueField{ get; set; }
    public String sObjVal{get;set;}
    public Integer randomJsIden{get;set;}
    
   
    public ComboBox_Con(){
        randomJsIden = getRandomNumber(1000000);
    }
    
    /*
    *Setter method to set the targetField
    ***/
    public void setTargetField(Object targetField){
        if(targetField == null){
            this.targetField = targetField;
        }
    }
    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = math.random() * size;
        return d.intValue();
    }
    
    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<SObject> getData(String sObjVal,String labelField,String valueField,String param){
        param = String.escapeSingleQuotes(param);
        return Database.query('select '+valueField+','+labelField+' from '+sObjVal+' where '+labelField+' like \'%'+param+'%\' AND rC_Bios__Active__c = true');
    }
    
    /*
    *Unit test method
    **/
    static testMethod void test_getData(){
        //create some test account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 200 ; i++){
            accountList.add(new Account(Name='Test'+i));
        }
        //insert hte records
        insert accountList;
        Test.startTest();
            System.assertEquals(accountList.size(),ComboBox_Con.getData('Account','Name','Id','T').size());
            System.assertEquals(1,ComboBox_Con.getData('Account','Name','Id','Test111').size());
            System.assertEquals(0,ComboBox_Con.getData('Account','Name','Id','xxxxxxx').size());
            ComboBox_Con controller = new ComboBox_Con();
            controller.setTargetField(null);
        Test.stopTest();
        
    }
}