from pathlib import Path
import json


def parse_line(files):
    products_dir = {}
    for file in files:
        with file.open(encoding="utf-8") as f:
            date_name = file.stem.split("_")
            products_list = []
            for line in f:
                products_list.append(json.loads(line))
            products_dir[date_name[1]] = products_list
    return products_dir


def summarize_file(list_p):
    summary = {}
    total = 0
    orders_cnt = 0
    for p in list_p:
        amount = p.get("total_amount")
        if amount is None or amount == "":
            continue
        # print(p.get("total_amount"))
        total += float(amount)
        orders_cnt += 1

    summary["orders_cnt"] = orders_cnt
    summary["total_amount"] = total
    return summary


def load_report(path):
    try:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


def main() -> None:
    data_dir = Path("incoming")
    list_path = sorted(data_dir.glob("*.jsonl"))

    if len(list_path) == 0:
        print("Нових файлів немає")
        return

    products = parse_line(list_path)
    dic_summarize = {}
    for k, v in products.items():
        dic_summarize[k] = summarize_file(v)

    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)
    summary_path = output_dir / "daily_report.json"
    old_summary = load_report(summary_path)
    old_summary.update(dic_summarize)
    with summary_path.open("w", encoding="utf-8") as f:
        json.dump(old_summary, f, ensure_ascii=False, indent=2)

    processed_dir = Path("processed")
    processed_dir.mkdir(exist_ok=True)

    for p in list_path:
        p.rename(processed_dir / p.name)


if __name__ == "__main__":
    main()
