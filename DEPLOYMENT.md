# Mocable GitHub Pages Deployment

This repository is prepared for GitHub Pages custom domain deployment.

## 1. GitHub Pages settings

Open the repository:

https://github.com/Magic-KD/Mocable

Go to:

Settings -> Pages

Use these settings:

- Source: Deploy from a branch
- Branch: main
- Folder: /root
- Custom domain: mocable.com
- Enforce HTTPS: enabled after DNS verification passes

The repository already includes:

- `index.html` as the root landing file
- `CNAME` with `mocable.com`

## 2. Spaceship DNS records

In Spaceship DNS, remove old parking/default A records for `mocable.com`, then add these records.

### Apex domain

| Type | Host | Value | TTL |
| --- | --- | --- | --- |
| A | @ | 185.199.108.153 | Automatic or 3600 |
| A | @ | 185.199.109.153 | Automatic or 3600 |
| A | @ | 185.199.110.153 | Automatic or 3600 |
| A | @ | 185.199.111.153 | Automatic or 3600 |

### WWW subdomain

| Type | Host | Value | TTL |
| --- | --- | --- | --- |
| CNAME | www | Magic-KD.github.io | Automatic or 3600 |

## 3. Verification

DNS may take several minutes to a few hours to propagate.

Check from PowerShell:

```powershell
Resolve-DnsName mocable.com
Resolve-DnsName www.mocable.com
```

Expected result:

- `mocable.com` should resolve to GitHub Pages IPs.
- `www.mocable.com` should resolve to `Magic-KD.github.io`.

