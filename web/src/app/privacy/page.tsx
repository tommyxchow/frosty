export default function Privacy() {
  return (
    <article className='prose prose-neutral mt-32 !max-w-none dark:prose-invert'>
      <h1>Privacy policy for Frosty</h1>
      <p>Last updated: May 2023</p>

      <p>
        Frosty is an unofficial open-source mobile Twitch client/app for iOS and
        Android. We are dedicated to protecting your privacy. Frosty does not
        collect or share any personal information. However, we may gather
        anonymous usage data and crash logs solely to improve the app. For more
        information, please refer to the sections below.
      </p>

      <h2>Third-party services</h2>
      <p>
        Frosty uses and interacts with the following services in order to
        provide the best experience possible:
      </p>

      <h3>Twitch</h3>
      <p>
        Frosty uses the official Twitch API to showcase live channels, connect
        to chat, and provide additional features. You can optionally log in with
        your Twitch account to access user-specific features, such as sending
        chat messages and viewing your followed channels.
      </p>
      <p>
        If you log in using Twitch, Frosty will only ask you for the necessary
        and required permissions to function. Frosty will then obtain your OAuth
        access token and send requests to receive and transmit data to Twitch
        only on your behalf. This access token is stored and encrypted locally
        on your device only.
      </p>
      <p>
        For more information on how Twitch handles your data, please refer to
        their privacy policy.
      </p>

      <h3>7TV, BetterTTV, and FrankerFaceZ</h3>
      <p>
        Frosty uses APIs from 7TV, BetterTTV (BTTV), and FrankerFaceZ (FFZ) to
        display custom badges and emotes in chat. When you visit your own
        channel, Frosty will request these services using your public Twitch ID
        or username to obtain emotes and badges associated with your channel.
      </p>
      <p>
        For more information on how 7TV, BTTV, and FFZ handle your data, please
        refer to their respective privacy policies.
      </p>

      <h3>Firebase</h3>
      <p>
        Frosty utilizes Firebase for crash logs, usage data, and analytics to
        aid in the development of new features, improvements, and bug fixes. The
        collected data is anonymous and does not contain any personal
        information. You can opt out of this data collection by turning off
        crash logs and analytics in the settings.
      </p>
      <p>For more information, please refer to the Firebase privacy policy.</p>

      <h2>Privacy policy updates</h2>
      <p>
        We may occasionally update this privacy policy, and the most recent
        version will always be available on this page. We recommend reviewing
        this privacy policy periodically for any changes. Changes to this
        privacy policy become effective when they are posted on this page.
      </p>

      <h2>Contact</h2>
      <p>
        If you have any questions or suggestions about this privacy policy,
        please feel free to contact us at contact@frostyapp.io.
      </p>
    </article>
  );
}
