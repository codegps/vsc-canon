/**
 * Construct date and time string from given arguments to get time in milliseconds.
 * @note YYYY/MM/DD hh:mm:ss
 */
args = WScript.Arguments;
dateTime = '';
for (i = 0; i < args.length; i++) {
    if (dateTime.length) {
        dateTime += ' ';
    }
    dateTime += args(i).replace(/\-/g, '/');
}
WScript.Echo(new Date(dateTime).getTime());
