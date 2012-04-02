
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Xrm Service Toolkit Test</title>
  <link rel="stylesheet" href="Scripts/qunit/qunit.css" type="text/css" media="screen" />
  <script src="Scripts/helper/PageData.js" type="text/javascript"></script>
  <script src="Scripts/helper/XrmPageTemplate.js" type="text/javascript"></script>
  <script type="text/javascript" src="Scripts/qunit/qunit.js"></script>
  <script type="text/javascript" src="Scripts/helper/XrmServiceToolkit.js"></script>
  <script type="text/javascript">

    var guidExpr = /^(\{)?([0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12})(\})?$/;
    var contactId;
    var birthDate = new Date(1955, 2, 20);
    var currentUserId, whoamiUserId;
    var accountId;

    //Test Rest and Soap Functions
    try {

        module("[Rest Functions]");

        test("Test XrmServiceToolkit.Rest.Create() method to create a new record", function () {

            var contact = {};
            contact.FirstName = "Diane";
            contact.LastName = "Morgan";
            contact.MiddleName = "<&>";
            contact.GenderCode = { Value: 2 };
            contact.CreditLimit = { Value: "2.00" };
            contact.BirthDate = birthDate;
            contact.DoNotEMail = true;
            contact.DoNotPhone = true;

            XrmServiceToolkit.Rest.Create(
                contact,
                "ContactSet",
                function (result) {
                    contactId = result.ContactId;
                    ok(guidExpr.test(result.ContactId), "Creating a contact should returned the new record's ID in GUID format. ");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Create() method to create a new record", function () {

            var account = {};
            account.Name = "Test Account Name";
            account.Description = "This account was created by the XrmServiceToolkit.Rest.Create() sample.";
            if (contactId != null) {
                //Set a lookup value
                account.PrimaryContactId = { Id: contactId, LogicalName: "contact" };
            }
            //Set a picklist value
            account.PreferredContactMethodCode = { Value: 2 }; //E-mail

            //Set a money value
            account.Revenue = { Value: "2000000.00" }; //Set Annual Revenue

            //Set a Boolean value
            account.DoNotPhone = true; //Do Not Allow

            //Add Two Tasks
            var today = new Date();
            var startDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 3); //Set a date three days in the future.

            var LowPriTask = { Subject: "Low Priority Task", ScheduledStart: startDate, PriorityCode: { Value: 0} }; //Low Priority Task
            var HighPriTask = { Subject: "High Priority Task", ScheduledStart: startDate, PriorityCode: { Value: 2} }; //High Priority Task
            account.Account_Tasks = [LowPriTask, HighPriTask];
            XrmServiceToolkit.Rest.Create(
                account,
                "AccountSet",
                function (result) {
                    accountId = result.AccountId;
                    ok(guidExpr.test(result.AccountId), "Creating a account should returned the new record's ID in GUID format. ");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Retrieve() method to retrieve a record", function () {

            XrmServiceToolkit.Rest.Retrieve(
                accountId,
                "AccountSet",
                null, null,
                function (result) {
                    var Id = result.AccountId;
                    equals(Id, accountId, "Retrieve() method should return the same account ID as Create() result. ");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Update() method to update a record", function () {

            var account = {};
            account.Name = "Updated Account Name";
            account.Address1_AddressTypeCode = { Value: 3 }; //Address 1: Address Type = Primary
            account.Address1_City = "Sammamish";
            account.Address1_Line1 = "123 Maple St.";
            account.Address1_PostalCode = "98074";
            account.Address1_StateOrProvince = "WA";
            account.EMailAddress1 = "someone@microsoft.com";

            XrmServiceToolkit.Rest.Update(
                accountId,
                account,
                "AccountSet",
                function () {
                    equals(true, true, "The record should have been updated.");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Associate() method to associate a record", function () {

            XrmServiceToolkit.Rest.Associate(
                contactId,
                "ContactSet",
                accountId,
                "AccountSet",
                "account_primary_contact",
                function () {
                    equals(true, true, "The record should have been associated.");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Disassociate() method to disassociate a record", function () {

            XrmServiceToolkit.Rest.Disassociate(
                    contactId,
                    "ContactSet",
                    accountId,
                    "account_primary_contact",
                    function () {
                        equals(true, true, "The record should have been disassociated.");
                    },
                    function (error) {
                        equal(true, false, error.message);
                    },
                    false
                );
        });

        test("Test XrmServiceToolkit.Rest.Delete(account) method to delete a record", function () {

            XrmServiceToolkit.Rest.Delete(
                accountId,
                "AccountSet",
                function () {
                    equals(true, true, "The record should have been deleted.");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.Delete(contact) method to delete a record", function () {

            XrmServiceToolkit.Rest.Delete(
                contactId,
                "ContactSet",
                function () {
                    equals(true, true, "The record should have been deleted.");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                false
            );
        });

        test("Test XrmServiceToolkit.Rest.RetrieveMultiple(contact) method to get the contacts", function () {

            XrmServiceToolkit.Rest.RetrieveMultiple(
                "ContactSet",
                "$select=ContactId, FullName",
                function (results) {
                    ok(results.length > 0, results.length.toString() + " records should have been retrieved.");
                },
                function (error) {
                    equal(true, false, error.message);
                },
                function onComplete() {

                },
                false
            );
        });

        module("[Soap Functions]");
        
        test("Test XrmServiceToolkit.Soap.Execute() method using WhoAmIRequest message to get current user's ID", function () {

            var request = "<request i:type='b:WhoAmIRequest' xmlns:a='http://schemas.microsoft.com/xrm/2011/Contracts' xmlns:b='http://schemas.microsoft.com/crm/2011/Contracts'>" +
                            "<a:Parameters xmlns:c='http://schemas.datacontract.org/2004/07/System.Collections.Generic' />" +
                            "<a:RequestId i:nil='true' />" +
                            "<a:RequestName>WhoAmI</a:RequestName>" +
                          "</request>";
            var whoAmI = XrmServiceToolkit.Soap.Execute(request);
            whoamiUserId = whoAmI.getElementsByTagName("a:Results")[0].childNodes[0].childNodes[1].text;
            ok(guidExpr.test(whoamiUserId), "WhoAmI request should returned a valid GUID. ");

        });

        test("Test XrmServiceToolkit.Soap.GetCurrentUserId() method to get current user's ID", function () {

            currentUserId = XrmServiceToolkit.Soap.GetCurrentUserId();
            equals(currentUserId, whoamiUserId, "getCurrentUserId() method should return the same user ID as WhoAmI request. ");

        });

        test("Test XrmServiceToolkit.Soap.IsCurrentUserInRole() method to check if current user is a System Administrator.", function () {

            var isSystemAdministrator = XrmServiceToolkit.Soap.IsCurrentUserRole("System Administrator");
            ok(isSystemAdministrator, "You ought to be a System Administrator to run test for isCurrentUserInRole() method. ");

        });

        test("Test XrmServiceToolkit.Soap.GetCurrentUserRoles() method to get all the system roles that the current user has been assigned to.", function () {

            var roles = XrmServiceToolkit.Soap.GetCurrentUserRoles();
            ok(roles.constructor.toString().indexOf("Array") != -1, "getCurrentUserRoles() method should an array of user roles. ");

        });

        test("Test XrmServiceToolkit.Soap.Create() method to create a CRM record (account)", function () {

            var createAccount = new XrmServiceToolkit.Soap.BusinessEntity("account");
            createAccount.attributes["name"] = "Test Account Name";
            createAccount.attributes["description"] = "This account was created by the XrmServiceToolkit.Soap.Create() sample.";
            createAccount.attributes["preferredcontactmethodcode"] = { value: 2, type: "OptionSetValue" };
            createAccount.attributes["revenue"] = { value: 2000.00, type: "Money" };
            createAccount.attributes["donotphone"] = false;

            accountId = XrmServiceToolkit.Soap.Create(createAccount);

            ok(guidExpr.test(accountId), "Creating a account should returned the new record's ID in GUID format. ");

        });

        test("Test XrmServiceToolkit.Soap.Create() method to create a CRM record (contact)", function () {

            var createContact = new XrmServiceToolkit.Soap.BusinessEntity("contact");
            createContact.attributes["firstname"] = "Diane";
            createContact.attributes["lastname"] = "Morgan";
            createContact.attributes["middlename"] = "<&>";   // Deliberate special characters to ensure that the toolkit can handle special characters correctly.
            createContact.attributes["gendercode"] = { value: 2, type: "OptionSetValue" };
            createContact.attributes["familystatuscode"] = { value: 1, type: "OptionSetValue" }; // Picklist : Single - 1
            createContact.attributes["creditlimit"] = { value: 2, type: "Money" };
            createContact.attributes["birthdate"] = birthDate;
            createContact.attributes["donotemail"] = true;
            createContact.attributes["donotphone"] = false;
            createContact.attributes["parentcustomerid"] = { id: accountId, logicalName: "account", type: "EntityReference" };

            contactId = XrmServiceToolkit.Soap.Create(createContact);

            ok(guidExpr.test(contactId), "Creating a contact should returned the new record's ID in GUID format. ");

        });
 
        test("Test XrmServiceToolkit.Soap.Update() method to update a CRM record (contact)", function () {

            equals(contactId, contactId, "ContactID");
            var updateContact = new XrmServiceToolkit.Soap.BusinessEntity("contact", contactId);
            updateContact.attributes["firstname"] = "Diane";
            updateContact.attributes["lastname"] = "Lopez";
            updateContact.attributes["donotpostalmail"] = null;
            updateContact.attributes["familystatuscode"] = { value: 2, type: "OptionSetValue" }; // Married

            var updateResponse = XrmServiceToolkit.Soap.Update(updateContact);

            ok(updateResponse === "", "The contact should be able to be updated.");
        });

        test("Test XrmServiceToolkit.Soap.Retrieve() method to retrieve a CRM record (contact)", function () {

            var cols = ["firstname", "lastname", "middlename", "familystatuscode", "ownerid", "creditlimit", "birthdate", "donotemail", "donotphone"];
            var retrievedContact = XrmServiceToolkit.Soap.Retrieve("contact", contactId, cols);

            equals(retrievedContact.attributes['lastname'].value, "Lopez", "A retrieve of just updated contact has proved that its last name has actually been updated. ");
            equals(retrievedContact.attributes['firstname'].value, "Diane", "firstname matches");
            equals(retrievedContact.attributes['middlename'].value, "<&>", "middlename matches");
            equals(retrievedContact.attributes['familystatuscode'].value, 2, "familystatuscode matches");
            equals(retrievedContact.attributes['familystatuscode'].type, "OptionSetValue", "CRM picklist's JavaScript type should be OptionSetValue");
            ok(CompareGuid(retrievedContact.attributes['ownerid'].id, currentUserId), "ownerid matches");
            equals(retrievedContact.attributes['creditlimit'].value, 2, "creditlimit matches");
            equals(retrievedContact.attributes['creditlimit'].type, "Money", "CRM number's JavaScript type should be Money");
            equals(retrievedContact.attributes['birthdate'].value.getTime(), birthDate.getTime(), "birthdate matches");
            equals(retrievedContact.attributes['donotemail'].value, true, "donotemail matches");
            equals(retrievedContact.attributes['donotemail'].type, "boolean", "CRM bit field's value type should be boolean (donotemail)");
            equals(retrievedContact.attributes['donotphone'].value, false, "donotphone matches");
            equals(retrievedContact.attributes['donotphone'].type, "boolean", "CRM bit's JavaScript type should be boolean (donotphone");
            same(typeof retrievedContact.attributes['donotpostalmail'], "undefined", "donotpostalmail matches");
        });

        test("Test XrmServiceToolkit.Soap.RetrieveMultiple() method to retrieve a CRM record (contact)", function () {

            var query =
                     "<a:ColumnSet>" +
                      "<a:AllColumns>false</a:AllColumns>" +
                      "<a:Columns xmlns:b='http://schemas.microsoft.com/2003/10/Serialization/Arrays'>" +
                        "<b:string>firstname</b:string>" +
                        "<b:string>lastname</b:string>" +
                        "<b:string>middlename</b:string>" +
                        "<b:string>familystatuscode</b:string>" +
                        "<b:string>ownerid</b:string>" +
                        "<b:string>creditlimit</b:string>" +
                        "<b:string>birthdate</b:string>" +
                        "<b:string>donotemail</b:string>" +
                        "<b:string>donotphone</b:string>" +
                      "</a:Columns>" +
                    "</a:ColumnSet>" +
                    "<a:Criteria>" +
                      "<a:Conditions />" +
                      "<a:FilterOperator>And</a:FilterOperator>" +
                      "<a:Filters>" +
                        "<a:FilterExpression>" +
                          "<a:Conditions>" +
                            "<a:ConditionExpression>" +
                              "<a:AttributeName>contactid</a:AttributeName>" +
                              "<a:Operator>Equal</a:Operator>" +
                              "<a:Values xmlns:b='http://schemas.microsoft.com/2003/10/Serialization/Arrays'>" +
                                "<b:anyType i:type='c:string' xmlns:c='http://www.w3.org/2001/XMLSchema'>"+ contactId +"</b:anyType>" +
                              "</a:Values>" +
                            "</a:ConditionExpression>" +
                          "</a:Conditions>" +
                          "<a:FilterOperator>And</a:FilterOperator>" +
                          "<a:Filters />" +
                        "</a:FilterExpression>" +
                      "</a:Filters>" +
                    "</a:Criteria>" +
                    "<a:Distinct>false</a:Distinct>" +
                    "<a:EntityName>contact</a:EntityName>" +
                    "<a:LinkEntities />" +
                    "<a:Orders />" +
                    "<a:PageInfo>" +
                      "<a:Count>0</a:Count>" +
                      "<a:PageNumber>0</a:PageNumber>" +
                      "<a:PagingCookie i:nil='true' />" +
                      "<a:ReturnTotalRecordCount>false</a:ReturnTotalRecordCount>" +
                    "</a:PageInfo>" +
                    "<a:NoLock>false</a:NoLock>";

            var retrievedContacts = XrmServiceToolkit.Soap.RetrieveMultiple(query);

            equals(retrievedContacts.length, 1, "only last created contact should be found");
            equals(retrievedContacts[0].attributes['lastname'].value, "Lopez", "A retrieve of just updated contact has proved that its last name has actually been updated. ");
            equals(retrievedContacts[0].attributes['firstname'].value, "Diane", "firstname matches");
            equals(retrievedContacts[0].attributes['middlename'].value, "<&>", "middlename matches");
            equals(retrievedContacts[0].attributes['familystatuscode'].value, 2, "familystatuscode matches");
            equals(retrievedContacts[0].attributes['familystatuscode'].type, "OptionSetValue", "CRM picklist's JavaScript type should be OptionSetValue");
            ok(CompareGuid(retrievedContacts[0].attributes['ownerid'].id, currentUserId), "ownerid matches");
            equals(retrievedContacts[0].attributes['creditlimit'].value, 2, "creditlimit matches");
            equals(retrievedContacts[0].attributes['creditlimit'].type, "Money", "CRM number's JavaScript type should be Money");
            equals(retrievedContacts[0].attributes['birthdate'].value.getTime(), birthDate.getTime(), "birthdate matches");
            equals(retrievedContacts[0].attributes['donotemail'].value, true, "donotemail matches");
            equals(retrievedContacts[0].attributes['donotemail'].type, "boolean", "CRM bit field's value type should be boolean (donotemail)");
            equals(retrievedContacts[0].attributes['donotphone'].value, false, "donotphone matches");
            equals(retrievedContacts[0].attributes['donotphone'].type, "boolean", "CRM bit's JavaScript type should be boolean (donotphone");
            same(typeof retrievedContacts[0].attributes['donotpostalmail'], "undefined", "donotpostalmail matches");

        });

        test("Test XrmServiceToolkit.Soap.Fetch() method to retrieve a CRM record (contact)", function () {

            var fetchXml =
                    "<fetch mapping='logical'>" +
                       "<entity name='contact'>" +
                          "<attribute name='contactid' />" +
                          "<attribute name='firstname' />" +
                          "<attribute name='lastname' />" +
                          "<attribute name='middlename' />" +
                          "<attribute name='familystatuscode' />" +
                          "<attribute name='ownerid' />" +
                          "<attribute name='creditlimit' />" +
                          "<attribute name='birthdate' />" +
                          "<attribute name='accountrolecode' />" +
                          "<attribute name='donotemail' />" +
                          "<attribute name='donotphone' />" +
                          "<filter>" +
                             "<condition attribute='contactid' operator='eq' value='" + contactId + "' />" +
                          "</filter>" +
                       "</entity>" +
                    "</fetch>";

            var retrievedContacts = XrmServiceToolkit.Soap.Fetch(fetchXml);

            equals(retrievedContacts.length, 1, "only last created contact should be found");
            equals(retrievedContacts[0].attributes['lastname'].value, "Lopez", "A retrieve of just updated contact has proved that its last name has actually been updated. ");
            equals(retrievedContacts[0].attributes['firstname'].value, "Diane", "firstname matches");
            equals(retrievedContacts[0].attributes['middlename'].value, "<&>", "middlename matches");
            equals(retrievedContacts[0].attributes['familystatuscode'].value, 2, "familystatuscode matches");
            equals(retrievedContacts[0].attributes['familystatuscode'].type, "OptionSetValue", "CRM picklist's JavaScript type should be OptionSetValue");
            ok(CompareGuid(retrievedContacts[0].attributes['ownerid'].id, currentUserId), "ownerid matches");
            equals(retrievedContacts[0].attributes['creditlimit'].value, 2, "creditlimit matches");
            equals(retrievedContacts[0].attributes['creditlimit'].type, "Money", "CRM number's JavaScript type should be Money");
            equals(retrievedContacts[0].attributes['birthdate'].value.getTime(), birthDate.getTime(), "birthdate matches");
            equals(retrievedContacts[0].attributes['donotemail'].value, true, "donotemail matches");
            equals(retrievedContacts[0].attributes['donotemail'].type, "boolean", "CRM bit field's value type should be boolean (donotemail)");
            equals(retrievedContacts[0].attributes['donotphone'].value, false, "donotphone matches");
            equals(retrievedContacts[0].attributes['donotphone'].type, "boolean", "CRM bit's JavaScript type should be boolean (donotphone");
            same(typeof retrievedContacts[0].attributes['donotpostalmail'], "undefined", "donotpostalmail matches");

        });

        test("Test XrmServiceToolkit.Soap.Fetch() method to do an aggregation query", function () {

            var fetchXml =
                "<fetch mapping='logical' aggregate='true'>" +
                   "<entity name='contact'>" +
                      "<attribute name='contactid' aggregate='count' alias='count' />" +
                      "<filter>" +
                         "<condition attribute='contactid' operator='eq' value='" + contactId + "' />" +
                      "</filter>" +
                   "</entity>" +
                "</fetch>";

            var fetchedContacts = XrmServiceToolkit.Soap.Fetch(fetchXml);

            equals(fetchedContacts.length, 1, "only one record should be returned when doing aggregation.");
            equals(fetchedContacts[0].attributes['count'].formattedValue, "1", "only one contact record would match the id.");
        });

        test("Test XrmServiceToolkit.Soap.QueryByAttribute() method to retrieve a CRM record (contact) using one criterion", function () {
            var queryOptions = {
                entityName: "contact",
                attributes: "contactid",
                values: contactId
            };
            var fetchedContacts = XrmServiceToolkit.Soap.QueryByAttribute(queryOptions); // Retrieve all fields (BAD Practice) with no sorting

            equals(fetchedContacts.length, 1, "only last created contact should be found");
        });

        test("Test XrmServiceToolkit.Soap.QueryByAttribute() method to retrieve a CRM record (contact) using two criteria", function () {
            var queryOptions = {
                entityName: "contact",
                attributes: ["firstname", "middlename", "lastname"],
                values: ["Diane", "<&>", "Lopez"],
                columnSet: ["firstname", "lastname", "middlename", "familystatuscode", "ownerid", "creditlimit", "birthdate", "donotemail", "donotphone"],
                orderby: ["firstname", "lastname"] // Order by firstname and then lastname even though we are only getting one record back
            };

            var fetchedContacts = XrmServiceToolkit.Soap.QueryByAttribute(queryOptions);

            ok(fetchedContacts.length >= 1, "at least there should be one matched contact record, which is what we just created");
        });

        test("Test XrmServiceToolkit.Soap.SetState() method to set a CRM record's status", function () {

            var response = XrmServiceToolkit.Soap.SetState("contact", "245DD529-8343-E111-8F5A-000C294FB247", 1, 2);
            ok(response == "SetState", "The contact can be deactivated. ");

        });

        test("Test XrmServiceToolkit.Soap.Associate() method to associate records through an 1:N relationship", function () {

            var account = new XrmServiceToolkit.Soap.BusinessEntity("account",accountId);
            var relatedAccounts = new Array();
            relatedAccounts[0] = account;
            var response = XrmServiceToolkit.Soap.Associate("account_primary_contact", "contact", contactId, "account", relatedAccounts);
            ok(response == "Associate", "The contact can be associated with account. ");

        });

        test("Test XrmServiceToolkit.Soap.Disassociate() method to disassociate records of an 1:N relationship", function () {

            var account = new XrmServiceToolkit.Soap.BusinessEntity("account", accountId);
            var relatedAccounts = new Array();
            relatedAccounts[0] = account;
            var response = XrmServiceToolkit.Soap.Disassociate("account_primary_contact", "contact", contactId, "account", relatedAccounts);
            ok(response == "Disassociate", "The contact can be disassociate with account. ");

        });

        test("Test XrmServiceToolkit.Soap.Delete() method to delete a CRM record (contact)", function () {

            var deleteResponse = XrmServiceToolkit.Soap.Delete("contact", contactId);
            ok(deleteResponse == "", "The contact can be deleted. ");

        });

        test("Test XrmServiceToolkit.Soap.Delete() method to delete a CRM record (account)", function () {

            var deleteResponse = XrmServiceToolkit.Soap.Delete("account", accountId);
            ok(deleteResponse == "", "The account can be deleted. ");

        });

        // Utility method to compare two GUID strings, return true if the GUID's are actually equal.
        var CompareGuid = function (guid1, guid2) {
            if (guid1 === null && guid2 === null)
                return true;

            if (guid1 === null || guid2 === null)
                return false;

            guid1 = guid1.toLowerCase(guid1);
            guid2 = guid2.toLowerCase(guid2);

            if (!guidExpr.test(guid1) || !guidExpr.test(guid2))
                return false;

            guid1 = guid1.replace(guidExpr, "$2");
            guid2 = guid2.replace(guidExpr, "$2");

            if (guid1 === guid2)
                return true;

            return false;
        };
    }
    catch (error) {
        alert(error.message);
    }

  </script>

</head>
<body>
    <h1 id="qunit-header">Xrm Service Toolkit Test - Functions</h1>
    <h2 id="qunit-banner"></h2>
    <div id="qunit-testrunner-toolbar"></div>
    <h2 id="qunit-userAgent"></h2>
    <ol id="qunit-tests"></ol></body>
</html>
