import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';

const receiverHtml = readFileSync(new URL('./index.html', import.meta.url), 'utf8');

test('receiver targets one second live latency', () => {
	assert.match(receiverHtml, /const TARGET_LATENCY_SECONDS = 1(?:\.0)?;/);
	assert.match(receiverHtml, /defaultPresentationDelay: TARGET_LATENCY_SECONDS,/);
});

test('receiver owns catch-up rate correction', () => {
	assert.match(receiverHtml, /const MAX_CATCHUP_PLAYBACK_RATE = 1\.1;/);
	assert.match(receiverHtml, /const CATCHUP_RATE_PER_SECOND_BEHIND = 0\.025;/);
	assert.match(receiverHtml, /maxPlaybackRate: 1,/);
	assert.match(receiverHtml, /minPlaybackRate: 1,/);
	assert.doesNotMatch(receiverHtml, /mediaElement\.playbackRate =/);
});

test('receiver performs a startup live seek only', () => {
	assert.match(receiverHtml, /const STARTUP_LIVE_SEEK_ATTEMPTS = 12;/);
	assert.match(receiverHtml, /correction: ok \? 'startupJumpToLive' : 'startupJumpFailed'/);
	assert.doesNotMatch(receiverHtml, /hardSeek/);
});
