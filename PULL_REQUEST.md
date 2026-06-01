# Update ScubaConfigApp: policy migration, SecuritySuite consolidation, Graph ID resolution, and baseline/run fixes #

## 🗣 Description ##

**ADDED:** Policy migration mapping CSV (`scuba-baseline-policy-migrations.csv`) and import-time auto-migration. When a YAML config referencing legacy policy IDs is imported, the app automatically remaps IDs to their current equivalents and notifies the user which policies were migrated and which require manual review due to policy splits.

**ADDED:** Required-field highlighting — fields that must be filled in before a config is valid are flagged with a red `*`.

**ADDED:** Graph ID resolution on import. Imported YAML files containing GUIDs are batch-resolved via the Microsoft Graph `getByIds` endpoint. Display names are shown as tooltips on list items. IDs that no longer exist in the directory are flagged with an orange-red strikethrough and a red dot on the policy card header.

**ADDED:** `ScubaConfigApp_Control_REFERENCE.md` — a full reference document covering every key in the control JSON, the application data flow, and the `graphQueries` schema including the new `directoryObjectType` field.

**ADDED:** `directoryObjectType` field added to all `graphQueries` entries in the control JSON. `Resolve-GraphIdsBatch` now derives the Graph API type strings entirely from the JSON config — no hardcoded endpoint-to-type mapping in PowerShell.

**UPDATED:** Walkthrough documentation updated to cover `-Online` mode, import validation behavior, policy migration, and orphaned ID flagging.

**UPDATED:** YAML export includes a `# Generated for: ScubaGear <version>` header comment.

**UPDATED:** Several helper modules were encoded as UTF-8 without BOM; all are now UTF-8 with BOM for consistent PowerShell loading.

**UPDATED:** The **Run ScubaGear** tab is disabled until **Preview & Generate** has been successfully run. The tab is re-disabled after any YAML import so the updated config must be previewed again before execution.

**FIXED:** When `-Online` was passed, baselines were being fetched from GitHub instead of loaded locally. The `-Online` switch controls tenant Graph connectivity only. `PullOnlineBaselines: true` in the JSON config controls whether baselines are fetched from GitHub.

**FIXED:** Removing policies from an imported YAML file did not actually remove them from the loaded config.

**FIXED:** Policy viewer internal policy cross-links now navigate correctly to the referenced policy.

**FIXED:** PowerBI now appears as a selectable product in the Annotations and Omissions tabs.

**FIXED:** **Run ScubaGear** was always importing from the gallery-installed module instead of the working branch. It now detects a local branch source and imports from it when applicable.

**FIXED:** ScubaGear Report Summary was using hardcoded output paths. Now reads defaults from `ScubaConfigDefaults.json`. Also fixed array serialization across `Start-Job` boundaries and OneDrive-redirected Documents folder detection.

**REMOVED:** `ScubaConfigAppBaselineHelper.psm1` — functionality consolidated into `ScubaConfigAppBaselineUIViewerHelper.psm1` and the repo build process.

> **Note:** While the diff appears large, a significant portion of the changes are UTF-8 BOM re-encoding of existing files with no logic changes.

## 💭 Motivation and context ##

The ScubaGear 1.8 release decoupled Defender policies into a new SecuritySuite product group and split several existing policies. Users importing YAML configs built against earlier versions need a safe upgrade path. This PR adds that migration layer so existing configurations can be carried forward without manual policy ID hunting.

The Graph ID resolution work ensures that exclusion lists containing GUIDs remain human-readable (display names as tooltips) and that stale IDs from deleted objects are surfaced immediately on import rather than silently producing invalid configs.

Resolves #1990
Resolves #2116
Resolves #2120
Resolves #2176

## 🧪 Testing ##

1. Import the module with `-Force` and launch `Start-SCuBAConfigApp`. Import the `full_config.yaml` sample file from the repo. Enter an organization name such as `example.onmicrosoft.com`.
2. Verify a popup appears for **Legacy Policy Migration Applied** listing auto-migrated policies and policies that need review due to splits.
3. Verify **Defender** is no longer selectable in the UI and has been replaced with **SecuritySuite**.
4. Navigate to **Exclusions**, **Annotate Policies**, and **Omit Policies** tabs and verify Defender is not present as a product tab in any of them.
5. Expand any SecuritySuite policy on any tab, click **View Baseline Policy**, and verify the Policy Viewer opens directly to that policy.
6. Click **Preview & Generate** and verify migration-related messages are displayed.
7. Verify products requiring review are highlighted with a red `*` under Exclusions and still retain their imported configuration.
8. Verify products requiring review are highlighted with a red `*` under Annotate Policies and retain their configuration (or can be cleared for newly decoupled policies).
9. Verify products requiring review are highlighted with a red `*` under Omit Policies and retain their configuration (or can be cleared for newly decoupled policies).
10. Verify clicking **Save** or **Dismiss Review** on a highlighted migrated policy card removes the highlight.
11. Verify multiple sensitive users can be added to the exclusion policy for `MS.SECURITYSUITE.2.1v1`.
12. Review all migrated policies, click **Preview & Generate**, and verify the YAML output contains all migrated policies. Dismissed policies should be absent.
13. Verify the generated YAML includes a header comment in the form `# Generated for: ScubaGear 1.8.0`.
14. Verify the YAML file saves successfully.
15. Launch the app and verify there are no errors on close. The debug log should end with `ScubaConfigApp closed successfully with no errors`.
16. Verify the saved YAML runs successfully via `Invoke-SCuBA` from the command line.
17. Run `Show-SCuBABaselinePolicyViewer` from the command line and verify Defender is not in the product list.
18. Read through the ScubaConfigApp walkthrough documentation and verify it is accurate and screenshots reflect the current UI.
19. Read through `ScubaConfigApp_Control_REFERENCE.md` and verify each section accurately describes its corresponding JSON key and behavior.

## 📷 Screenshots ##

Screenshots for all new features are included in `docs/images/`:

| Feature | File |
|---------|------|
| Legacy policy migration notification | `scubaconfigapp_legacynotification.png` |
| Migrated policy card | `scubaconfigapp_migratedpolicy.png` |
| Required field highlighting | `scubaconfigapp_required.png` |
| Review required indicator | `scubaconfigapp_reviewrequired.png` |
| Exclusions — saved state | `scubaconfigapp_exclusions_saved.png` |
| Graph — Get Groups picker | `scubaconfigapp_online_getgroups.png` |
| Graph — orphaned ID on import | `scubaconfigapp_online_importingnotfound.png` |
| Graph — remove not-found item | `scubaconfigapp_online_removenotfound.png` |
| Policy viewer split screen | `scubaconfigapp_policyviewersplitscreen.png` |
| Policy review help | `scubaconfigapp_policyreviewhelp.png` |
| Run tab | `scubaconfigapp_run.png` |
| Split policies | `scubaconfigapp_splitpolicies.png` |
| Advanced app auth | `scubaconfigapp_advanced_appauth.png` |
| Baseline policy viewer | `scubabaselinepolicyviewer.png` |

## ✅ Pre-approval checklist ##

- [ ] This PR has an informative and human-readable title.
- [ ] PR targets the correct parent branch (e.g., main or release-name) for merge.
- [ ] Changes are limited to a single goal - *eschew scope creep!*
- [ ] Changes are sized such that they do not touch excessive number of files.
- [ ] *All* future TODOs are captured in issues, which are referenced in code comments.
- [ ] These code changes follow the ScubaGear [content style guide](https://github.com/cisagov/ScubaGear/blob/main/CONTENTSTYLEGUIDE.md).
- [ ] Related issues these changes resolve are linked preferably via [closing keywords](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword).
- [ ] All relevant type-of-change labels added.
- [ ] All relevant project fields are set.
- [ ] All relevant repo and/or project documentation updated to reflect these changes.
- [ ] Unit tests added/updated to cover PowerShell and Rego changes.
- [ ] Functional tests added/updated to cover PowerShell and Rego changes.
- [ ] All relevant functional tests passed.
- [ ] All automated checks (e.g., linting, static analysis, unit/smoke tests) passed.

## ✅ Pre-merge checklist ##

- [ ] PR passed smoke test check.
- [ ] Feature branch has been rebased against changes from parent branch, as needed.
- [ ] Resolved all merge conflicts on branch.
- [ ] Squash all commits into one PR level commit using the `Squash and merge` button.

## ✅ Post-merge checklist ##

- [ ] Feature branch deleted after merge to clean up repository.
- [ ] Close issues resolved by this PR if the [closing keywords](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword) did not activate.
- [ ] Verified that all checks pass on parent branch (e.g., main or release-name) after merge.
**ADDED:** Import now checks for policies that have been changed; attempts to auto-migrate policies to current equivalents.
**ADDED:** Helper to highlight required input fields when not filled in.
**ADDED:** JSON Reference file added covering the full UI configuration schema and application data flow.

**UPDATED:** ScubaGear detailed walkthrough documentation updated to cover migration workflows.
**UPDATED:** YAML export now includes ScubaGear version in the file header comment.
**UPDATED:** Some helper module files were not encoded as UTF-8 with BOM; encoding corrected.
**UPDATED:** Run ScubaGear tab is not enabled until Preview & Generate has been successfully run. This requires users to ensure their configuration is valid before attempting an execution run. The tab is also re-disabled after a YAML import so the updated config must be previewed again.

**FIXED:** When using `-Online`, baselines were being pulled from GitHub instead of the local schema file. The `-Online` switch controls tenant connectivity only. `PullOnlineBaselines: true` in the JSON config controls whether baselines are fetched from GitHub.
**FIXED:** Removing policies from an imported file did not actually remove them.
**FIXED:** Policy viewer internal policy links now navigate correctly to the referenced policy.
**FIXED:** PowerBI now appears in the product selection menu for Annotations and Omissions tabs.
**FIXED:** Run ScubaGear was always importing from the gallery-installed module instead of the current branch. It now detects whether it is running from a local branch and imports from there when applicable.
**FIXED:** ScubaGear Report Summary was using hardcoded paths and folder names. Now reads defaults from `ScubaConfigDefaults.json`. Also fixed array serialization across `Start-Job` boundaries and OneDrive-redirected Documents folder detection.

**REMOVED:** `ScubaConfigAppBaselineHelper.psm1` is no longer needed as its functionality is now part of the repo build process.

Resolves #1990
Resolves #2116
Resolves #2120
Resolves #2176

---

## Tests

1. Import the module with `-Force` and launch `Start-SCuBAConfigApp`. Import the `full_config.yaml` sample file provided in the repo. Enter an organization name such as `example.onmicrosoft.com`.

2. Verify a popup appears for **Legacy Policy Migration Applied** indicating:
   - Auto-migrated policies were applied
   - Policies that need review due to policy splits are listed

3. Verify **Defender** is no longer selectable in the UI and has been replaced with **SecuritySuite**.

4. Navigate to the **Exclusions** tab and verify Defender is not a selectable product tab.

5. Navigate to the **Annotate Policies** tab and verify Defender is not a selectable product tab.

6. Navigate to the **Omit Policies** tab and verify Defender is not a selectable product tab.

7. Expand any SecuritySuite policy on any tab, click **View Baseline Policy**, and verify the Policy Viewer opens directly to that policy.

8. Click **Preview & Generate** and verify any migration-related messages are displayed.

9. Verify products requiring review are highlighted with a red `*` under **Exclusions** and still maintain their imported configuration.

10. Verify products requiring review are highlighted with a red `*` under **Annotate Policies** and still maintain their configuration, or can be cleared due to new decoupled policies.

11. Verify products requiring review are highlighted with a red `*` under **Omit Policies** and still maintain their configuration, or can be cleared due to new decoupled policies.

12. Verify that clicking **Save** or **Dismiss Review** on a highlighted migrated policy card removes the highlight.

13. Verify multiple sensitive users can be added to the exclusion policy for `MS.SECURITYSUITE.2.1v1`.

14. Review all migrated policies, then click **Preview & Generate** and verify the YAML output contains all newly migrated policies and that any dismissed policies are absent.

15. Verify the generated YAML file includes a header comment in the form:
    ```
    # Generated for: ScubaGear 1.8.0
    ```

16. Verify the YAML file can be saved successfully.

17. Launch the ScubaGear app and verify there are no errors on close. The debug log should end with `ScubaConfigApp closed successfully with no errors`.

18. Verify the saved YAML can be run via `Invoke-SCuBA` from the command line without errors.

19. From the command line run `Show-SCuBABaselinePolicyViewer` and verify Defender is not present in the product list.

20. Read through the ScubaConfigApp walkthrough documentation and verify it is accurate and screenshots reflect current UI.

21. Read through `ScubaConfigApp_Control_REFERENCE.md` and verify each section accurately describes its corresponding JSON key and behavior.
