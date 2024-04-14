namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;
using System.Apps;
using System.Environment;

page 50100 "AL Objects Launcher"
{
    ApplicationArea = All;
    Caption = 'AL Objects Launcher';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "AllObjWithCaption";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            Group(Filters)
            {
                field(ObjectType; ObjectType)
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the value of the Object Type field.';
                    trigger OnValidate()
                    begin
                        FilterType();
                    end;
                }
            }
            repeater(GroupName)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the object type.';
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the object ID.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the name of the object.';
                    trigger OnDrillDown()
                    begin
                        OpenObject();
                    end;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the caption of the object.';
                }
                field(AppName; GetAppName())
                {
                    ApplicationArea = all;
                    Caption = 'App Name';
                    ToolTip = 'Specifies the value of the App Name field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Open)
            {
                ApplicationArea = All;
                Caption = 'Open';
                Image = Open;
                ShortcutKey = Return;
                ToolTip = 'Executes the Open action.';
                trigger OnAction();
                begin
                    OpenObject();
                end;
            }
            action(Fields)
            {
                ApplicationArea = all;
                Caption = 'Fields';
                Image = Accounts;
                RunObject = page "Fields Lookup";
                RunPageLink = TableNo = field("Object ID");
                Visible = ObjectType = ObjectType::Table;
            }
            action(PublishedEvents)
            {
                ApplicationArea = all;
                Caption = 'Published Events';
                Image = "Event";

                trigger OnAction()
                begin
                    LaunchPublishedEvents();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Open_Promoted; Open)
                {
                }
                actionref(Fields_Promoted; Fields)
                {
                }
                actionref(PublishedEvents_Promoted; PublishedEvents)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FilterType();
    end;

    local procedure OpenObject()
    var
        TableDataEditor: Page "Table Data Editor";
    begin
        case Rec."Object Type" of
            Rec."Object Type"::Codeunit:
                Codeunit.Run(Rec."Object ID");
            Rec."Object Type"::Page:
                Page.Run(Rec."Object ID");
            Rec."Object Type"::Report:
                Report.run(Rec."Object ID");
            Rec."Object Type"::Table, Rec."Object Type"::TableData:
                begin
                    TableDataEditor.SetTableID(Rec."Object ID");
                    TableDataEditor.RunModal();
                end;
        end;
    end;

    local procedure FilterType()
    begin
        case ObjectType of
            ObjectType::Table:
                Rec.SetRange("Object Type", Rec."Object Type"::TableData);
            ObjectType::Page:
                Rec.SetRange("Object Type", Rec."Object Type"::Page);
            ObjectType::Report:
                Rec.SetRange("Object Type", Rec."Object Type"::Report);
            ObjectType::Codeunit:
                Rec.SetRange("Object Type", Rec."Object Type"::Codeunit);
        end;
        if rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure GetAppName(): Text
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        NAVAppInstalledApp.SetRange("Package ID", Rec."App Package ID");
        if NAVAppInstalledApp.FindFirst() then
            exit(NAVAppInstalledApp.Name);
    end;

    local procedure LaunchPublishedEvents()
    var
        EventSubscription: Record "Event Subscription";
    begin
        case ObjectType of
            ObjectType::Table:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Table);
            ObjectType::Page:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Page);
            ObjectType::Report:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Report);
            ObjectType::Codeunit:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        end;
        EventSubscription.SetRange("Publisher Object ID", Rec."Object ID");
        page.Run(page::"Event Subscriptions", EventSubscription);
    end;

    var
        ObjectType: Option Table,Page,Report,Codeunit;
}