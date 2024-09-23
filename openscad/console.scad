module warn_if(condition, message) {
    if (condition) {
        echo(str("WARNING: ", message));
    }
}