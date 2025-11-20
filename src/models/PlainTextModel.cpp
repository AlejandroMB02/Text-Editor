#include "PlainTextModel.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

PlainTextModel::PlainTextModel(QObject *parent)
    : QAbstractListModel(parent),
      m_modified(false)
{
}

/* =============================
 *         BASE MODEL API
 * ============================= */

int PlainTextModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return static_cast<int>(m_lines.size());
}

QVariant PlainTextModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int row = index.row();
    if (row < 0 || row >= (int)m_lines.size())
        return QVariant();

    if (role == LineRole)
        return m_lines[row];

    return QVariant();
}

bool PlainTextModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || role != LineRole)
        return false;

    int row = index.row();
    if (row < 0 || row >= (int)m_lines.size())
        return false;

    QString newLine = value.toString();

    if (m_lines[row] != newLine)
    {
        m_lines[row] = newLine;
        emit dataChanged(index, index, { LineRole });
        setModified(true);
    }

    return true;
}

Qt::ItemFlags PlainTextModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> PlainTextModel::roleNames() const
{
    return {
        { LineRole, "line" }
    };
}

/* =============================
 *          PROPERTIES
 * ============================= */

QString PlainTextModel::filePath() const
{
    return m_filePath;
}

bool PlainTextModel::isModified() const
{
    return m_modified;
}

void PlainTextModel::setFilePath(const QString &path)
{
    if (m_filePath == path)
        return;

    m_filePath = path;
    emit filePathChanged();
}

/* =============================
 *          INTERNALS
 * ============================= */

void PlainTextModel::setModified(bool modified)
{
    if (m_modified == modified)
        return;

    m_modified = modified;
    emit modifiedChanged();
}

/* =============================
 *          OPERATIONS
 * ============================= */

bool PlainTextModel::load()
{
    if (m_filePath.isEmpty()) {
        qWarning() << "No file path set!";
        return false;
    }

    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Could not open file:" << m_filePath;
        return false;
    }

    QTextStream stream(&file);

    beginResetModel();
    m_lines.clear();

    while (!stream.atEnd()) {
        m_lines.push_back(stream.readLine());
    }

    endResetModel();

    setModified(false);
    return true;
}

bool PlainTextModel::save()
{
    if (m_filePath.isEmpty()) {
        qWarning() << "No file path set!";
        return false;
    }

    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Could not open file for writing:" << m_filePath;
        return false;
    }

    QTextStream stream(&file);

    for (const QString &line : m_lines) {
        stream << line << "\n";
    }

    setModified(false);
    return true;
}

/* =============================
 *      EDIT OPERATIONS
 * ============================= */

void PlainTextModel::insertLine(int index, const QString &text)
{
    if (index < 0 || index > (int)m_lines.size())
        return;

    beginInsertRows(QModelIndex(), index, index);
    m_lines.insert(m_lines.begin() + index, text);
    endInsertRows();

    setModified(true);
}

void PlainTextModel::removeLine(int index)
{
    if (index < 0 || index >= (int)m_lines.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_lines.erase(m_lines.begin() + index);
    endRemoveRows();

    setModified(true);
}

void PlainTextModel::appendLine(const QString &text)
{
    int index = static_cast<int>(m_lines.size());

    beginInsertRows(QModelIndex(), index, index);
    m_lines.push_back(text);
    endInsertRows();

    setModified(true);
}
