from pathlib import Path
import json


def parse_line(line):
    order = json.loads(line)
    amount = order.get("total_amount")
    if amount is None or amount == "":
        return None
    order["total_amount"] = float(amount)
    return order


def summarize_file(path):
    orders_cnt = 0
    total_amount = 0
    with path.open(encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            order = parse_line(line)
            if order is None:
                continue
            orders_cnt += 1
            total_amount += order["total_amount"]
    return {"orders_cnt": orders_cnt, "total_amount": total_amount}


def load_report(path):
    try:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


def save_report(report, path):
    path.parent.mkdir(exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)


def move_to_processed(path, processed_dir):
    processed_dir.mkdir(exist_ok=True)
    path.rename(processed_dir / path.name)


def main() -> None:
    incoming_dir = Path("incoming")
    report_path = Path("output") / "daily_report.json"
    processed_dir = Path("processed")

    files = sorted(incoming_dir.glob("*.jsonl"))
    if not files:
        print("Нових файлів немає")
        return

    new_days = {}
    for path in files:
        date = path.stem.split("_")[1]
        new_days[date] = summarize_file(path)

    report = load_report(report_path)
    report.update(new_days)
    save_report(report, report_path)

    for path in files:
        move_to_processed(path, processed_dir)


if __name__ == "__main__":
    main()