# iOS App Architecture (SwiftUI)

```
Captionary/
 ├─ CaptionaryApp.swift
 ├─ Models/
 │   ├─ CaptionRequest.swift
 │   └─ CaptionVariant.swift
 ├─ ViewModels/
 │   ├─ WizardVM.swift
 │   ├─ PaywallVM.swift
 │   └─ SessionVM.swift
 ├─ Views/
 │   ├─ OnboardingView.swift
 │   ├─ Wizard/
 │   │   ├─ MoodStep.swift
 │   │   ├─ MediaStep.swift
 │   │   ├─ GoalStep.swift
 │   │   └─ StyleStep.swift
 │   ├─ ResultsView.swift
 │   ├─ PaywallView.swift
 │   └─ SettingsView.swift
 ├─ Services/
 │   ├─ SupabaseClient.swift
 │   ├─ EdgeAPI.swift
 │   ├─ CaptionEngine.swift
 │   ├─ CostRouter.swift
 │   └─ PurchaseManager.swift
 └─ Resources/
     ├─ Secrets.plist
     └─ Assets.xcassets
```
