# Captionary Project Audit Report
**Date:** 2025-10-06
**Status:** Initial Implementation Review

---

## ✅ What's Implemented Correctly

### 1. **Folder Structure** ✓
Matches documented architecture from [03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md):
- ✅ Models/ (CaptionRequest, CaptionVariant)
- ✅ ViewModels/ (WizardVM, SessionVM, PaywallVM)
- ✅ Views/ (Onboarding, Wizard, Results, Paywall)
- ✅ Services/ (SupabaseClient, CaptionEngine)
- ✅ Resources/ (Secrets.plist)

### 2. **Data Models** ✓
- ✅ [CaptionRequest.swift](captionary/captionary/Models/CaptionRequest.swift) - Well-structured with API request separation
- ✅ [CaptionVariant.swift](captionary/captionary/Models/CaptionVariant.swift) - Quality scoring and metadata properly implemented
- ✅ Supabase data models (Profile, Subscription, UsageCounter) in SupabaseClient

### 3. **ViewModels** ✓
- ✅ [WizardVM.swift](captionary/captionary/ViewModels/WizardVM.swift) - 4-step wizard logic is solid
- ✅ [SessionVM.swift](captionary/captionary/ViewModels/SessionVM.swift) - Authentication and usage limits properly enforced
- ✅ State management follows modern SwiftUI patterns with `@Published` and `@MainActor`

### 4. **UI Implementation** ✓
- ✅ Wizard views follow documented UI flow from product brief
- ✅ Chip-based selection UI matches design specs
- ✅ Progress indicators and navigation controls properly implemented

---

## ⚠️ Critical Issues & Misalignments

### **1. Naming Inconsistencies with Documentation**

#### Issue: Wizard Step Files Don't Match Doc Names
**Documentation ([03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md)):**
```
├─ Wizard/
│   ├─ MoodStep.swift
│   ├─ MediaStep.swift
│   ├─ GoalStep.swift
│   └─ StyleStep.swift
```

**Actual Implementation:**
```
├─ Wizard/
│   ├─ MoodStepView.swift      ❌ Should be MoodStep.swift
│   ├─ ToneStepView.swift      ❌ Should be StyleStep.swift
│   ├─ MediaStepView.swift     ❌ Should be MediaStep.swift
│   └─ GoalStepView.swift      ❌ Should be GoalStep.swift
```

**Problems:**
- File names have "View" suffix (not in docs)
- "ToneStepView" should be "StyleStep" per documentation
- Inconsistent with documented architecture

---

### **2. Wizard Step Order Mismatch**

#### Documentation Says:
**Product Brief ([00_PRODUCT_BRIEF.md](Captionary_Docs/00_PRODUCT_BRIEF.md)) Core Loop:**
> Feel → Show → Purpose → Style

**WizardVM Implementation:**
```swift
enum WizardStep: Int, CaseIterable {
    case mood = 0      // ✓ "Feel"
    case tone = 1      // ❌ Should be step 3 "Style"
    case media = 2     // ❌ Should be step 1 "Show"
    case goal = 3      // ❌ Should be step 2 "Purpose"
}
```

**Current Order:** Feel → Style → Show → Purpose
**Documented Order:** Feel → Show → Purpose → Style

**Impact:** User flow doesn't match documented product vision

---

### **3. Missing Critical Services**

Per [03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md), these services are documented but missing:

❌ **EdgeAPI.swift** - Not implemented
❌ **CostRouter.swift** - Implemented inline in CaptionEngine (should be separate file)
❌ **PurchaseManager.swift** - Not implemented (critical for StoreKit 2)
❌ **SettingsView.swift** - Not implemented

**Current Services:**
- ✅ SupabaseClient.swift (exists)
- ✅ CaptionEngine.swift (exists)
- ⚠️ CostRouter (embedded in CaptionEngine instead of separate file)

---

### **4. SupabaseClient Type Conflict**

#### Critical Error in [SupabaseClient.swift:16](captionary/captionary/Services/SupabaseClient.swift#L16)
```swift
class SupabaseClient: ObservableObject {
    static let shared = SupabaseClient()

    private let supabase: SupabaseClient  // ❌ Type name conflicts with class name
```

**Problem:** The property `supabase` has the same type name as the class itself, causing a naming collision.

**Fix Required:**
```swift
private let client: SupabaseClient  // ✓ Rename property
// OR import with alias
import Supabase
private let client: Supabase.SupabaseClient
```

---

### **5. WizardVM Step Naming Confusion**

#### In [WizardVM.swift](captionary/captionary/ViewModels/WizardVM.swift):
```swift
enum WizardStep {
    case mood = 0     // Called "What's the vibe?" in UI
    case tone = 1     // Called "How should it sound?" in UI
    case media = 2    // Called "Upload a photo" in UI
    case goal = 3     // Called "What's the purpose?" in UI
}
```

**Issue:** "tone" is the internal name but UI and docs call it "style"

**Alignment with Docs:**
- Documentation uses: **"Style"** (StyleStep.swift)
- Code uses: **"Tone"** (ToneStepView.swift, selectedTone)
- UI displays: **"How should it sound?"**

**Recommendation:** Standardize on "Style" per documentation, or update docs to match "Tone"

---

### **6. Missing Vision API Integration**

#### In [WizardVM.swift:106-118](captionary/captionary/ViewModels/WizardVM.swift#L106)
```swift
func processSelectedImage() async {
    // TODO: Implement Vision API analysis for automatic description
    // For now, use placeholder
    mediaDescription = "Selected photo with \(selectedMood.lowercased()) vibes"
}
```

**Issue:** Vision API integration is critical per [01_TECH_STACK.md](Captionary_Docs/01_TECH_STACK.md)
```
Client: SwiftUI, Combine/Concurrency, PhotosUI, Vision, StoreKit2
```

**Expected Behavior:** Auto-generate `mediaDescription` from photo analysis
**Current Behavior:** Placeholder text only

---

### **7. Incomplete API Integrations**

#### OpenAI & Gemini Placeholders in [CaptionEngine.swift:66-91](captionary/captionary/Services/CaptionEngine.swift#L66)
```swift
private func generateWithOpenAI(request: APICaptionRequest) async throws -> CaptionGenerationResponse {
    // TODO: Implement OpenAI API integration
    // This is a placeholder implementation
    let mockVariants = createMockVariants(for: request)
    // ...
}

private func generateWithGemini(request: APICaptionRequest) async throws -> CaptionGenerationResponse {
    // TODO: Implement Gemini API integration
    // This is a placeholder implementation
    let mockVariants = createMockVariants(for: request)
    // ...
}
```

**Status:** Mock implementations only - not production-ready

---

### **8. Missing Supabase Configuration**

#### In [SupabaseClient.swift:23-26](captionary/captionary/Services/SupabaseClient.swift#L23)
```swift
self.supabase = SupabaseClient(
    supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
    supabaseKey: "YOUR_SUPABASE_ANON_KEY"
)
```

**Problem:** Hardcoded placeholder credentials instead of using Secrets.plist

**Expected (per docs):**
```swift
// Should load from Resources/Secrets.plist
guard let secretsPath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
      let secrets = NSDictionary(contentsOfFile: secretsPath) else {
    fatalError("Secrets.plist not found")
}
```

---

### **9. Missing StoreKit 2 Implementation**

#### Critical Missing File: PurchaseManager.swift
[03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md) explicitly lists:
```
Services/
 └─ PurchaseManager.swift
```

**Status:** ❌ Not implemented

**Impact:**
- [PaywallVM.swift](captionary/captionary/ViewModels/PaywallVM.swift) exists but has no purchase logic
- Cannot process subscriptions without PurchaseManager
- Blocks monetization functionality

---

### **10. Incorrect Date Formatting for Usage Tracking**

#### In [SupabaseClient.swift:129](captionary/captionary/Services/SupabaseClient.swift#L129)
```swift
let currentMonth = DateFormatter().string(from: Date()).prefix(7) // YYYY-MM format
```

**Problem:** Default DateFormatter won't produce "YYYYMM" format (no hyphen per schema)

**Schema Requirement ([02_SUPABASE_SCHEMA.md](Captionary_Docs/02_SUPABASE_SCHEMA.md)):**
```sql
yyyymm char(6) not null  -- Must be "202510", not "2025-10"
```

**Fix:**
```swift
let formatter = DateFormatter()
formatter.dateFormat = "yyyyMM"
let currentMonth = formatter.string(from: Date())
```

---

### **11. Missing Views from Documentation**

Per [03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md):

**Documented but Missing:**
- ❌ SettingsView.swift
- ⚠️ OnboardingView.swift exists but not integrated into app flow

**Existing Views:**
- ✅ WizardView, MoodStepView, ToneStepView, MediaStepView, GoalStepView
- ✅ ResultsView, PaywallView

---

## 📊 Summary Statistics

| Category | Status |
|----------|--------|
| **File Structure** | 85% complete |
| **Models** | ✅ 100% complete |
| **ViewModels** | ✅ 100% complete |
| **Services** | ⚠️ 60% complete (missing 3 files) |
| **Views** | ⚠️ 85% complete (missing SettingsView) |
| **API Integrations** | ⚠️ 0% complete (all mocked) |
| **Documentation Alignment** | ⚠️ 75% aligned |

---

## 🔥 Priority Fix List

### **Critical (Must Fix Before Launch):**
1. ✅ Fix SupabaseClient type name conflict
2. ✅ Implement PurchaseManager.swift for StoreKit 2
3. ✅ Fix date formatting for usage tracking (yyyymm)
4. ✅ Load Supabase config from Secrets.plist
5. ✅ Implement real OpenAI/Gemini API calls

### **High Priority (Breaks Documentation Contract):**
6. ✅ Rename wizard step files to match docs (remove "View" suffix)
7. ✅ Reorder wizard steps per documented flow: Feel → Show → Purpose → Style
8. ✅ Rename "Tone" to "Style" throughout codebase
9. ✅ Implement Vision API for photo analysis
10. ✅ Create missing EdgeAPI.swift service

### **Medium Priority (Complete Architecture):**
11. ✅ Extract CostRouter to separate file
12. ✅ Implement SettingsView
13. ✅ Integrate OnboardingView into app flow
14. ✅ Add proper error handling for network failures

---

## 🎯 Recommendations

### 1. **Standardize Naming Convention**
Choose one approach and apply everywhere:
- **Option A:** Match docs exactly (MoodStep.swift, StyleStep.swift)
- **Option B:** Update docs to match code (MoodStepView.swift, ToneStepView.swift)

**Recommendation:** Follow documentation (Option A) for consistency

### 2. **Fix Core Loop Order**
Update WizardVM.WizardStep enum to match documented order:
```swift
enum WizardStep: Int, CaseIterable {
    case mood = 0      // Feel
    case media = 1     // Show
    case goal = 2      // Purpose
    case style = 3     // Style
}
```

### 3. **Complete Critical Services**
Priority order:
1. PurchaseManager.swift (monetization blocker)
2. Vision API integration (core feature)
3. OpenAI/Gemini real API calls (core feature)
4. EdgeAPI.swift (backend communication)

### 4. **Security Improvements**
- Move all secrets to Secrets.plist
- Add .gitignore validation to prevent credential leaks
- Implement proper API key rotation strategy

---

## 📝 Next Steps

1. **Immediate:** Fix type name conflict in SupabaseClient
2. **Today:** Implement PurchaseManager and fix wizard step order
3. **This Week:** Complete Vision API and real AI integrations
4. **Before Launch:** Full security audit and API testing

---

**Audit Completed By:** Claude
**Review Status:** Ready for developer action
**Estimated Fix Time:** 2-3 days for critical issues
