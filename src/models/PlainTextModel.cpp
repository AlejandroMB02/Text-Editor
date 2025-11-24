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
        emit contentChanged();
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
    QHash<int, QByteArray> roles;
    roles[LineRole] = "line";
    return roles;
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

QString PlainTextModel::content() const
{
    // 1. Convertir std::vector<QString> a QVector<QString>
    QVector<QString> qVectorLines(m_lines.begin(), m_lines.end());
    
    // 2. Usar QVector<QString> para crear un QStringList y luego unir.
    // O más conciso, crear el QStringList directamente y luego unir:
    return QStringList(qVectorLines.toList()).join(QLatin1String("\n"));
}

void PlainTextModel::setFilePath(const QString &path)
{
    if (m_filePath == path)
        return;

    m_filePath = path;
    emit filePathChanged();
}

void PlainTextModel::setContent(const QString &text)
{
    // No hacer nada si el contenido es el mismo
    if (content() == text)
        return;

    // Notificar a las vistas que el modelo va a cambiar drásticamente
    beginResetModel();

    // Dividir el texto completo en líneas
    QList<QString> qlines = text.split('\n');
    m_lines.assign(qlines.begin(), qlines.end());

    setModified(true);
    emit contentChanged();

    // Notificar a las vistas que el modelo ha cambiado
    endResetModel();
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
    QString fullText = stream.readAll(); // Lee todo el contenido
    file.close();

    QList<QString> qlines = fullText.split('\n');

    beginResetModel();
    m_lines.assign(qlines.begin(), qlines.end()); // Asignación usando iteradores
    endResetModel();

    // Emitir signals después de la carga
    emit contentChanged();
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
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        qWarning() << "Could not open file for writing:" << m_filePath;
        return false;
    }

    QTextStream out(&file);
    // Escribir el contenido completo
    out << content();

    file.close();

    setModified(false); // No modificado después de guardar con éxito
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
    emit contentChanged();
}

void PlainTextModel::removeLine(int index)
{
    if (index < 0 || index >= (int)m_lines.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_lines.erase(m_lines.begin() + index);
    endRemoveRows();

    setModified(true);
    emit contentChanged();
}

void PlainTextModel::appendLine(const QString &text)
{
    int index = static_cast<int>(m_lines.size());

    beginInsertRows(QModelIndex(), index, index);
    m_lines.push_back(text);
    endInsertRows();

    setModified(true);
    emit contentChanged();
}
