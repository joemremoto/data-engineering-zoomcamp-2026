# Security Checklist for GCP Credentials

Use this checklist to ensure your GCP credentials are secure when working across multiple machines.

## Initial Setup (Do Once)

- [ ] Created `credentials/` directory in project root
- [ ] Downloaded GCP service account JSON key from GCP Console
- [ ] Saved JSON key as `credentials/gcp-service-account.json`
- [ ] Copied `.env.example` to `.env`
- [ ] Filled in actual values in `.env` file
- [ ] Verified credentials are gitignored: `git check-ignore credentials/gcp-service-account.json .env`
- [ ] Ran verification script: `python verify_credentials.py` or `.\verify_credentials.ps1`
- [ ] Tested GCP connection: `python example_gcp_usage.py`

## Before Each Git Commit

- [ ] Run `git status` to verify no credentials are staged
- [ ] Double-check no `.json` files with credentials are being committed
- [ ] Ensure `.env` file is not in git staging area

## When Setting Up on Second Machine

- [ ] **DO NOT** commit credentials to git
- [ ] Transfer credentials using one of these secure methods:
  - [ ] Password manager (recommended: 1Password, Bitwarden, LastPass)
  - [ ] Encrypted file transfer (GPG, 7-Zip with password)
  - [ ] Private cloud storage (temporarily, delete after)
  - [ ] Encrypted USB drive
- [ ] Use the **SAME** file structure on both machines:
  ```
  credentials/gcp-service-account.json
  .env
  ```
- [ ] Run verification script on the second machine
- [ ] Delete credentials from any temporary storage locations

## Regular Security Practices

- [ ] Never share credentials via:
  - [ ] Unencrypted email
  - [ ] Slack or other chat platforms
  - [ ] Public cloud links
  - [ ] Screenshot or copy-paste to unsecured locations
- [ ] Rotate service account keys periodically (every 90 days recommended)
- [ ] Use service accounts with minimal necessary permissions
- [ ] Review GCP IAM permissions regularly
- [ ] Delete old/unused service account keys from GCP Console

## If Credentials Are Compromised

1. [ ] Immediately disable the service account key in GCP Console
2. [ ] Create a new service account key
3. [ ] Update the key on both machines
4. [ ] Review GCP audit logs for unauthorized access
5. [ ] If committed to git by accident:
   - [ ] Revoke the key immediately in GCP Console
   - [ ] Remove from git history (use `git filter-repo` or BFG Repo-Cleaner)
   - [ ] Force push the cleaned history (coordinate with team if applicable)
   - [ ] Create new service account and key

## Quick Security Test

Run these commands to verify security:

```bash
# Check what files would be committed
git status

# Check if credentials are properly ignored
git check-ignore -v credentials/gcp-service-account.json .env

# Search for any JSON files that might be staged
git ls-files "*.json"

# Check if .env is being tracked
git ls-files ".env"
```

**Expected output:**
- `credentials/gcp-service-account.json` and `.env` should be listed as ignored
- `git ls-files "*.json"` should NOT show your credentials file
- `git ls-files ".env"` should return nothing (empty)

## Credential Management Best Practices

### ✅ DO:
- Store credentials in `credentials/` directory
- Use `.env` file for configuration
- Keep credentials local to each machine
- Use password managers for syncing
- Rotate keys regularly
- Use minimal IAM permissions
- Verify .gitignore is working

### ❌ DON'T:
- Commit credentials to git
- Share via unencrypted channels
- Use overly permissive service accounts
- Store credentials in cloud without encryption
- Leave old keys active indefinitely
- Hard-code credentials in source files
- Share credentials across projects unnecessarily

## Questions?

If you're unsure about any security aspect, refer to:
- [CREDENTIALS_SETUP.md](./CREDENTIALS_SETUP.md) - Detailed setup guide
- [GCP Security Best Practices](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
- [Google Cloud Authentication Docs](https://cloud.google.com/docs/authentication)

---

**Last Updated:** 2026-03-13  
**Remember:** When in doubt, err on the side of caution. It's better to regenerate credentials than to risk a security breach.
