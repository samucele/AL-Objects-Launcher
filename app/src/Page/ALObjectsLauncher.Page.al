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
            group(Filters)
            {
                field(ObjectTypeFilter; ObjectTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Select the type of AL object to display in the list. Choose from Table, Page, Report, or Codeunit to filter the visible objects.';
                    trigger OnValidate()
                    begin
                        ApplyObjectTypeFilter();
                    end;
                }
            }
            repeater(ObjectList)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the type of the AL object, such as Table, Page, Report, or Codeunit.';
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the unique numeric identifier of the AL object.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the internal name of the AL object. Click to open or run the object directly.';
                    trigger OnDrillDown()
                    begin
                        OpenObject(false);
                    end;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the translated caption of the AL object as displayed to end users.';
                }
                field(AppName; GetAppName())
                {
                    ApplicationArea = All;
                    Caption = 'App Name';
                    ToolTip = 'Shows the name of the extension (app) that contains this AL object.';
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
                ToolTip = 'Opens or runs the selected AL object. Tables open in the Table Data Editor, pages and reports are launched directly, and codeunits are executed.';
                trigger OnAction()
                begin
                    OpenObject(false);
                end;
            }
            action(OpenWithFilters)
            {
                ApplicationArea = All;
                Caption = 'Open With Filters';
                Image = FilterLines;
                ToolTip = 'Opens the selected table in the Table Data Editor and immediately displays the filter dialog so you can define which records to load.';
                trigger OnAction()
                begin
                    OpenObject(true);
                end;
            }
            action(Fields)
            {
                ApplicationArea = All;
                Caption = 'Fields';
                Image = Accounts;
                RunObject = page "Fields Lookup";
                RunPageLink = TableNo = field("Object ID");
                ToolTip = 'Opens the Fields Lookup page showing all fields defined on the selected table.';
                Visible = ObjectTypeFilter = ObjectTypeFilter::Table;
            }
            action(PublishedEvents)
            {
                ApplicationArea = All;
                Caption = 'Published Events';
                Image = "Event";
                ToolTip = 'Shows all published integration and business events for the selected object, including subscriber details.';
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
                actionref(OpenWithFilters_Promoted; OpenWithFilters)
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
    var
        InstalledApp: Record "NAV App Installed App";
    begin
        ApplyObjectTypeFilter();

        // Pre-cache app names to avoid per-row queries
        InstalledApp.SetLoadFields(Name, "Package ID");
        if InstalledApp.FindSet() then
            repeat
                if not AppNameCache.ContainsKey(InstalledApp."Package ID") then
                    AppNameCache.Add(InstalledApp."Package ID", InstalledApp.Name);
            until InstalledApp.Next() = 0;
    end;

    local procedure OpenObject(WithFilters: Boolean)
    var
        TableDataEditor: Page "Table Data Editor";
    begin
        case Rec."Object Type" of
            Rec."Object Type"::Codeunit:
                Codeunit.Run(Rec."Object ID");
            Rec."Object Type"::Page:
                Page.Run(Rec."Object ID");
            Rec."Object Type"::Report:
                Report.Run(Rec."Object ID");
            Rec."Object Type"::Table, Rec."Object Type"::TableData:
                begin
                    TableDataEditor.SetTableNumber(Rec."Object ID");
                    if WithFilters then
                        TableDataEditor.OpenFilterDialog(true);
                    TableDataEditor.RunModal();
                end;
        end;
    end;

    local procedure ApplyObjectTypeFilter()
    begin
        case ObjectTypeFilter of
            ObjectTypeFilter::Table:
                Rec.SetRange("Object Type", Rec."Object Type"::TableData);
            ObjectTypeFilter::Page:
                Rec.SetRange("Object Type", Rec."Object Type"::Page);
            ObjectTypeFilter::Report:
                Rec.SetRange("Object Type", Rec."Object Type"::Report);
            ObjectTypeFilter::Codeunit:
                Rec.SetRange("Object Type", Rec."Object Type"::Codeunit);
        end;
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure GetAppName(): Text
    begin
        if AppNameCache.ContainsKey(Rec."App Package ID") then
            exit(AppNameCache.Get(Rec."App Package ID"));
    end;

    local procedure LaunchPublishedEvents()
    var
        EventSubscription: Record "Event Subscription";
    begin
        case ObjectTypeFilter of
            ObjectTypeFilter::Table:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Table);
            ObjectTypeFilter::Page:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Page);
            ObjectTypeFilter::Report:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Report);
            ObjectTypeFilter::Codeunit:
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        end;
        EventSubscription.SetRange("Publisher Object ID", Rec."Object ID");
        Page.Run(Page::"Event Subscriptions", EventSubscription);
    end;

    var
        AppNameCache: Dictionary of [Guid, Text];
        ObjectTypeFilter: Option Table,Page,Report,Codeunit;
}
