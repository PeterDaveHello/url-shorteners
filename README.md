# URL Shorteners

[![Build Status](https://img.shields.io/travis/com/PeterDaveHello/url-shorteners/master.svg?style=flat-square)](https://app.travis-ci.com/PeterDaveHello/url-shorteners)
[![GitHub license](https://img.shields.io/github/license/PeterDaveHello/url-shorteners?style=flat-square)](https://github.com/PeterDaveHello/url-shorteners/blob/master/LICENSE)

A comprehensive collection of over one thousand URL shortener domains for various purposes such as whitelist/allowlist creation, blacklist/blocklist implementation, or domain trustworthiness assessment. Trusted by NextDNS, RethinkDNS, ControlD, dnslow.me, and various OSINT projects, these high-quality lists are designed to enhance network security, privacy protection, and reduce false positives in domain risk evaluations. Please use these lists at your own risk.

Keep in mind that the data in this repository will not be updated in real-time, as maintaining the lists requires significant effort. Contributions are welcome - feel free to report missing domains, false positives, or submit a donation to support the project.

Domains that are false positives or were previously used as URL shorteners but are now inactive will not be listed in the `list` file but will appear in the `inactive` file.

## Direct Links

Subscribe or download the files using the links below:

- Active URL shorteners: <https://raw.githubusercontent.com/PeterDaveHello/url-shorteners/master/list>
- Inactive URL shorteners: <https://raw.githubusercontent.com/PeterDaveHello/url-shorteners/master/inactive>

## Usage Scenarios

These domain lists can be applied in various network environments for diverse purposes, including:

- Directly used as a whitelist/allowlist or blacklist/blocklist
- Minimizing false positives in security and privacy protection measures
- Evaluating domain trustworthiness as a part of risk assessment processes

## Contribute

Your assistance in maintaining and improving these lists is greatly appreciated. To report missing domains, false positives, or any other issues, kindly submit an issue or pull request on GitHub.

## License

This project is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License(CC-BY-SA-4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

## Managing Domains

A shell script `manage_domains.sh` is provided to help manage the domains in the `list` and `inactive` files. The script ensures that the files remain sorted and comments are not affected.

### Usage

To add a new domain to the list file:

```sh
./manage_domains.sh add <domain>
```

To move an inactive domain to the inactive list:

```sh
./manage_domains.sh move <domain>
```
