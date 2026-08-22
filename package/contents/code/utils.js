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

    if (!duration || duration <= 0) {
        return speedData;
    }

    for (const key in nextTransferData) {
        if (prevTransferData && key in prevTransferData) {
            const prev = prevTransferData[key];
            const next = nextTransferData[key];
            speedData[key] = {
                down: ((next.rx - prev.rx) * 1000) / duration,
                up: ((next.tx - prev.tx) * 1000) / duration,
                downTotal: nextTransferData[key].rx,
                upTotal: nextTransferData[key].tx,
            };
        }
    }

    return speedData;
}

function totalText(value) {
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
