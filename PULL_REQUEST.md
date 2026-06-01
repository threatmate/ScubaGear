# Description

**ADDED:** Migration spreadsheet mapping file for legacy policy ID translation.
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
