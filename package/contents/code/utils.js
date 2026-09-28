const NET_DATA_SOURCE =
    "awk -v OFS=, 'NR > 2 { print substr($1, 1, length($1)-1), $2, $10 }' /proc/net/dev";

function parseTransferData(data) {
    const transferData = {};

    if (!data) {
        return transferData;
    }

    for (const line of data.trim().split("\n")) {
        if (!line) continue;
        const [name, rx, tx] = line.split(",");

        if (!name || name === "lo") {
            continue;
        }

        transferData[name] = { rx: Number(rx) || 0, tx: Number(tx) || 0 };
    }

    return transferData;
}

function calcSpeedData(prevTransferData, nextTransferData, duration) {
    const speedData = {};

    if (!nextTransferData) {
        return speedData;
    }

    const hasDuration = duration && duration > 0;

    for (const key in nextTransferData) {
        const next = nextTransferData[key];
        const prev = (prevTransferData && key in prevTransferData) ? prevTransferData[key] : null;
        speedData[key] = {
            down: (prev && hasDuration) ? Math.max(0, ((next.rx - prev.rx) * 1000) / duration) : 0,
            up: (prev && hasDuration) ? Math.max(0, ((next.tx - prev.tx) * 1000) / duration) : 0,
            downTotal: next.rx,
            upTotal: next.tx,
        };
    }

    return speedData;
}

function totalText(value) {
    value = Number(value) || 0;
    let unit;
    if (value >= 1024 * 1024 * 1024) {
        value /= 1024 * 1024 * 1024;
        unit = "GiB";
    } else if (value >= 1024 * 1024) {
        value /= 1024 * 1024;
        unit = "MiB";
    } else if (value >= 1024) {
        value /= 1024;
        unit = "KiB";
    } else {
        unit = "B";
    }
    return (Math.round(value * 10) / 10).toFixed(1) + " " + unit;
}
