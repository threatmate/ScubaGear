package securitysuite_test
import rego.v1

ConnFilter:= {
    "IPAllowList": [],
    "EnableSafeList": false,
    "Name": "A"
}
    
AdminAuditLogConfig := {
    "Identity": "Admin Audit Log Settings",
    "UnifiedAuditLogIngestionEnabled": true
}

ScubaConfig := {
    "OutPath": ".",
    "OutRegoFileName": "TestResults",
    "SecuritySuite": {
    }
}

ProtectionAlerts := [
    {
        "Name": "Suspicious email sending patterns detected",
        "Disabled": false
    },
    {
        "Name": "Suspicious Email Forwarding Activity",
        "Disabled": false
    },
    {
        "Name": "Messages have been delayed",
        "Disabled": false
    },
    {
        "Name": "Tenant restricted from sending unprovisioned email",
        "Disabled": false
    },
    {
        "Name": "Tenant restricted from sending email",
        "Disabled": false
    },
    {
        "Name": "A potentially malicious URL click was detected",
        "Disabled": false
    },
    {
        "Name": "Suspicious connector activity",
        "Disabled": false
    }
]

DefaultPolicy := {
    "Identity": "Default",
    "IsDefault": true,
    "RecommendedPolicyType": "Custom",
    "SpamAction": "MoveToJmf",
    "HighConfidenceSpamAction": "MoveToJmf",
    "PhishSpamAction": "Quarantine",
    "HighConfidencePhishAction": "Quarantine",
    "AllowedSenderDomains": []
}

StandardPresetPolicy := {
    "Identity": "Standard Preset Security Policy1659535429826",
    "IsDefault": false,
    "RecommendedPolicyType": "Standard",
    "SpamAction": "MoveToJmf",
    "HighConfidenceSpamAction": "MoveToJmf",
    "PhishSpamAction": "Quarantine",
    "HighConfidencePhishAction": "Quarantine",
    "AllowedSenderDomains": []
}

StrictPresetPolicy := {
    "Identity": "Strict Preset Security Policy1659535429827",
    "IsDefault": false,
    "RecommendedPolicyType": "Strict",
    "SpamAction": "Quarantine",
    "HighConfidenceSpamAction": "Quarantine",
    "PhishSpamAction": "Quarantine",
    "HighConfidencePhishAction": "Quarantine",
    "AllowedSenderDomains": []
}

CustomPolicy := {
    "Identity": "Custom Policy A",
    "IsDefault": false,
    "RecommendedPolicyType": "Custom",
    "SpamAction": "MoveToJmf",
    "HighConfidenceSpamAction": "Quarantine",
    "PhishSpamAction": "Quarantine",
    "HighConfidencePhishAction": "Quarantine",
    "AllowedSenderDomains": []
}

# EOP preset rules with both Standard and Strict enabled
ProtectionPolicyRulesEnabled := [
    {
        "Identity": "Standard Preset Security Policy",
        "HostedContentFilterPolicy": "Standard Preset Security Policy1659535429826",
        "State": "Enabled"
    },
    {
        "Identity": "Strict Preset Security Policy",
        "HostedContentFilterPolicy": "Strict Preset Security Policy1659535429827",
        "State": "Enabled"
    }
]

# Custom policy rule - enabled
CustomPolicyRuleEnabled := [
    {
        "Identity": "Custom Policy A Rule",
        "HostedContentFilterPolicy": "Custom Policy A",
        "State": "Enabled"
    }
]

# Custom policy rule - disabled
CustomPolicyRuleDisabled := [
    {
        "Identity": "Custom Policy A Rule",
        "HostedContentFilterPolicy": "Custom Policy A",
        "State": "Disabled"
    }
]

