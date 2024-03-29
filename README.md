# CI Ampel

**Hint: 'Ampel' is the german word for traffic light.**

This piece of code switches lights, that are physically plugged into a USB controllable wall socket, on or off, depending on failed Jenkins jobs or Gitlab CI pipelines.

It also sends a short message to a pre-defined Slack channel '#ampel' if you want it.

![Screenshot](jenkins-light.jpg)

## Dependencies

1. Ruby >= 2.0

2. Bundler

3. [Controllable USB wall socket](https://www.amazon.de/gp/product/B00BAQZJ4K/ref=oh_aui_detailpage_o06_s01?ie=UTF8&psc=1)

4. [SiS-PM  (Silver Shield PM) Control for Linux 3.0](http://sispmctl.sourceforge.net/)

## Howto use it?

```
bundle install
```

Create a *.env* file and place three environment variables in it.

```
touch .env
```

```
BASE_URI=https://your.jenkins.or.gitlab.uri.without.a.path
USER=user
PASS=password
TOKEN=123456789
SLACK_HOOK_URI=https://hooks.slack.com/services/foo/bar
```

Remember to specify user and password OR a token. Not all of them at the same time.

### Fire it up:

#### Jenkins:

Run the 'CI Ampel' for Jenkins projects:

```
bin/ampel -j
```

#### Gitlab CI:

Run the 'CI Ampel' for Gitlab projects:

```
bin/ampel -g
```

If you want to auto-fix your pipelines by rerunning failed jobs, run:

```
bin/ampel -g -r
```

#### Both (Jenkins or Gitlab CI)

If you want to send a message to a Slack channel:

```
bin/ampel -(j|g) -s
```

If you want to use 'CI Ampel' locally (don't switch lights):

```
bin/ampel -(j|g) -d
```

Add a cron job to your system.

```
*/1 * * * *  ruby /home/pi/ampel/bin/ampel 2>/dev/null
```

#### Help

```
bin/ampel -h
```

```
This services switches a controllable USB wall socket depending on a Jenkins or Gitlab failes
jobs/pipelines status.

Usage: ruby ./ampel.rb [OPTIONS]

Options:
    -j, --jenkins                    use Jenkins as automation server
    -g, --gitlab                     use gitlab as automation server
    -r, --rerun                      rerun failed gitlab jobs
    -d, --dry-run                    do not switch any lights on or off
    -s, --slack                      send slack message in case of an failure
    -h, --help                       help```
```

## Output

```
OK: Everything is fine again! Green light is on. :-)
```

If you execute `DEBUG=true bin/ampel -g`, 'CI Ampel' will output the names of failing Gitlab CI pipelines.

## Contribute

[Click here for more information.](CONTRIBUTING.md)

## License

[Click here for more information.](LICENSE)
