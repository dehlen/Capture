import AppKit
import os

class IntegrationsPreferencesViewController: PreferencesViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        os_log(.info, log: .preferences, "General preferences loaded")
    }

    @IBAction func showPersonalAccessTokenHelp(_ sender: Any) {
        os_log(.info, log: .preferences, "Show help for access token")
        let personalAccessTokenHelpUrl = URL(string: "https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html")!
        NSWorkspace.shared.open(personalAccessTokenHelpUrl)
    }
}
