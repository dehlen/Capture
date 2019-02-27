import AppKit

class IntegrationsPreferencesViewController: PreferencesViewController {

    @IBAction func showPersonalAccessTokenHelp(_ sender: Any) {
        let personalAccessTokenHelpUrl = URL(string: "https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html")!
        NSWorkspace.shared.open(personalAccessTokenHelpUrl)
    }
}
