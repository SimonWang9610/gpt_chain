String buildToolPrompt(String input, [String? output]) {
  if (output == null) {
    return 'This tool did not return useful information for $input';
  } else {
    return 'This tool found: $output for $input';
  }
}
